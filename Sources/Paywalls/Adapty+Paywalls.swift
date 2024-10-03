//
//  Adapty+Paywalls.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 01.11.2023
//

import Foundation

private let log = Log.default

extension Adapty {
    /// Adapty allows you remotely configure the products that will be displayed in your app. This way you don't have to hardcode the products and can dynamically change offers or run A/B tests without app releases.
    ///
    /// Read more on the [Adapty Documentation](https://docs.adapty.io/v2.0.0/docs/displaying-products)
    ///
    /// - Parameters:
    ///   - placementId: The identifier of the desired paywall. This is the value you specified when you created the paywall in the Adapty Dashboard.
    ///   - locale: The identifier of the paywall [localization](https://docs.adapty.io/docs/paywall#localizations).
    ///             This parameter is expected to be a language code composed of one or more subtags separated by the "-" character. The first subtag is for the language, the second one is for the region (The support for regions will be added later).
    ///             Example: "en" means English, "en-US" represents US English.
    ///             If the parameter is omitted, the paywall will be returned in the default locale.
    ///   - fetchPolicy: by default SDK will try to load data from server and will return cached data in case of failure. Otherwise use `.returnCacheDataElseLoad` to return cached data if it exists.
    /// - Returns: The ``AdaptyPaywall`` object. This model contains the list of the products ids, paywall's identifier, custom payload, and several other properties.
    /// - Throws: An ``AdaptyError`` object
    public nonisolated static func getPaywall(
        placementId: String,
        locale: String? = nil,
        fetchPolicy: AdaptyPaywall.FetchPolicy = .default,
        loadTimeout: TimeInterval = .defaultLoadPaywallTimeout
    ) async throws -> AdaptyPaywall {
        let loadTimeout = loadTimeout.allowedLoadPaywallTimeout
        let locale = locale.map { AdaptyLocale(id: $0) } ?? .defaultPaywallLocale

        let logParams: EventParameters = [
            "placement_id": placementId,
            "locale": locale,
            "fetch_policy": fetchPolicy,
            "load_timeout": loadTimeout,
        ]

        return try await withActivatedSDK(methodName: .getPaywall, logParams: logParams) { sdk in
            let paywall = try await sdk.getPaywall(
                placementId,
                locale,
                fetchPolicy,
                loadTimeout
            )
            AdaptyUI.sendImageUrlsToObserver(paywall)

            return paywall
        }
    }

    private func getPaywall(
        _ placementId: String,
        _ locale: AdaptyLocale,
        _ fetchPolicy: AdaptyPaywall.FetchPolicy,
        _ loadTimeout: TimeInterval
    ) async throws -> AdaptyPaywall {
        guard let profileId = profileManager?.profileId else {
            return try await fetchFallbackPaywall(
                profileStorage.profileId,
                placementId,
                locale,
                httpFallbackSession
            )
        }

        do {
            return try await withThrowingTimeout(seconds: loadTimeout - 0.5) {
                try await self.fetchPaywall(
                    profileId,
                    placementId,
                    locale,
                    fetchPolicy
                )
            }
        } catch let error where error.canUseFallbackServer {
            return try await fetchFallbackPaywall(
                profileId,
                placementId,
                locale,
                httpFallbackSession
            )
        } catch {
            guard let chosen = try profileManager(with: profileId).orThrows
                .paywallsCache
                .getPaywallWithFallback(byPlacementId: placementId, locale: locale)
            else {
                throw error.asAdaptyError ?? AdaptyError.fetchPaywallFailed(unknownError: error)
            }
            Adapty.trackEventIfNeed(chosen)
            return chosen.value
        }
    }

    private func fetchPaywall(
        _ profileId: String,
        _ placementId: String,
        _ locale: AdaptyLocale,
        _ fetchPolicy: AdaptyPaywall.FetchPolicy
    ) async throws -> AdaptyPaywall {
        let manager = try profileManager(with: profileId).orThrows

        let fetchTask = Task {
            try await fetchPaywall(
                profileId,
                placementId,
                locale
            )
        }

        let cached = manager
            .paywallsCache
            .getPaywallByLocale(locale, orDefaultLocale: true, withPlacementId: placementId)?
            .withFetchPolicy(fetchPolicy)?
            .value

        let paywall =
            if let cached {
                cached
            } else {
                try await fetchTask.value
            }

        return paywall
    }

    private func fetchPaywall(
        _ profileId: String,
        _ placementId: String,
        _ locale: AdaptyLocale
    ) async throws -> AdaptyPaywall {
        let (segmentId, cached, isTestUser): (String, AdaptyPaywall?, Bool) = try {
            let manager = try profileManager(with: profileId).orThrows
            return (
                manager.profile.value.segmentId,
                manager.paywallsCache.getPaywallByLocale(locale, orDefaultLocale: false, withPlacementId: placementId)?.value,
                manager.profile.value.isTestUser
            )
        }()

        do {
            var response = try await httpSession.fetchPaywallVariations(
                apiKeyPrefix: apiKeyPrefix,
                profileId: profileId,
                placementId: placementId,
                locale: locale,
                segmentId: segmentId,
                cached: cached,
                disableServerCache: isTestUser
            )

            if let manager = tryProfileManagerOrNil(with: profileId) {
                response = manager.paywallsCache.savedPaywallChosen(response)
            }

            Adapty.trackEventIfNeed(response)
            return response.value

        } catch {
            guard error.wrongProfileSegmentId,
                  try await updateSegmentId(for: profileId, oldSegmentId: segmentId)
            else {
                throw error.asAdaptyError ?? AdaptyError.fetchPaywallFailed(unknownError: error)
            }

            return try await fetchPaywall(profileId, placementId, locale)
        }

        func updateSegmentId(for profileId: String, oldSegmentId: String) async throws -> Bool {
            let manager = try profileManager(with: profileId).orThrows
            guard manager.profile.value.segmentId == oldSegmentId else { return true }
            return await manager.getProfile().segmentId != oldSegmentId
        }
    }

    func fetchFallbackPaywall(
        _ profileId: String,
        _ placementId: String,
        _ locale: AdaptyLocale,
        _ session: some FetchFallbackPaywallVariationsExecutor
    ) async throws -> AdaptyPaywall {
        let result: AdaptyPaywallChosen

        do {
            let (cached, isTestUser): (AdaptyPaywall?, Bool) = {
                guard let manager = tryProfileManagerOrNil(with: profileId) else { return (nil, false) }
                return (
                    manager.paywallsCache.getPaywallByLocale(locale, orDefaultLocale: false, withPlacementId: placementId)?.value,
                    manager.profile.value.isTestUser
                )
            }()

            var response = try await session.fetchFallbackPaywallVariations(
                apiKeyPrefix: apiKeyPrefix,
                profileId: profileId,
                placementId: placementId,
                locale: locale,
                cached: cached,
                disableServerCache: isTestUser
            )

            if let manager = tryProfileManagerOrNil(with: profileId) {
                response = manager.paywallsCache.savedPaywallChosen(response)
            }

            result = response

        } catch {
            let chosen =
                if let manager = tryProfileManagerOrNil(with: profileId) {
                    manager.paywallsCache.getPaywallWithFallback(byPlacementId: placementId, locale: locale)
                } else {
                    Adapty.fallbackPaywalls?.getPaywall(byPlacementId: placementId, profileId: profileId)
                }

            guard let chosen else {
                throw error.asAdaptyError ?? AdaptyError.fetchPaywallFailed(unknownError: error)
            }

            result = chosen
        }

        Adapty.trackEventIfNeed(result)
        return result.value
    }
}

extension TimeInterval {
    public static let defaultLoadPaywallTimeout: TimeInterval = 5.0
    static let minimumLoadPaywallTimeout: TimeInterval = 1.0

    var allowedLoadPaywallTimeout: TimeInterval {
        let minimum: TimeInterval = .minimumLoadPaywallTimeout
        guard self < minimum else { return self }
        log.warn("The  paywall load timeout parameter cannot be less than \(minimum)s")
        return minimum
    }
}

private extension Error {
    var canUseFallbackServer: Bool {
        let error = unwrapped
        if error is TimeoutError { return true }
        if let httpError = error as? HTTPError { return Backend.canUseFallbackServer(httpError) }
        return false
    }

    var wrongProfileSegmentId: Bool {
        let error = unwrapped
        if let httpError = error as? HTTPError { return Backend.wrongProfileSegmentId(httpError) }
        return false
    }
}
