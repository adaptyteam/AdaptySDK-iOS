//
//  Adapty+PaywallsForDefaultAudience.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 12.08.2024
//

import Foundation

extension Adapty {
    /// This method enables you to retrieve the paywall from the Default Audience without having to wait for the Adapty SDK to send all the user information required for segmentation to the server.
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
    public nonisolated static func getPaywallForDefaultAudience(
        placementId: String,
        locale: String? = nil,
        fetchPolicy: AdaptyPaywall.FetchPolicy = .default
    ) async throws -> AdaptyPaywall {
        let locale = locale.map { AdaptyLocale(id: $0) } ?? .defaultPaywallLocale

        let logParams: EventParameters = [
            "placement_id": placementId,
            "locale": locale,
            "fetch_policy": fetchPolicy,
        ]

        return try await withActivatedSDK(methodName: .getPaywallForDefaultAudience, logParams: logParams) { sdk in
            let paywall = try await sdk.getPaywallForDefaultAudience(
                placementId,
                locale,
                fetchPolicy
            )

            Adapty.sendImageUrlsToObserver(paywall)
            return paywall
        }
    }

    private func getPaywallForDefaultAudience(
        _ placementId: String,
        _ locale: AdaptyLocale,
        _ fetchPolicy: AdaptyPaywall.FetchPolicy
    ) async throws -> AdaptyPaywall {
        let manager = profileManager
        let profileId = manager?.profileId ?? profileStorage.profileId

        let fetchTask = Task {
            try await fetchPaywallForDefaultAudience(
                profileId,
                placementId,
                locale
            )
        }

        let cached = manager?
            .paywallsStorage
            .getPaywallByLocale(locale, orDefaultLocale: true, withPlacementId: placementId, withVariationId: nil)?
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

    private func fetchPaywallForDefaultAudience(
        _ profileId: String,
        _ placementId: String,
        _ locale: AdaptyLocale
    ) async throws -> AdaptyPaywall {
        let (cached, isTestUser): (AdaptyPaywall?, Bool) = {
            guard let manager = tryProfileManagerOrNil(with: profileId) else { return (nil, false) }
            return (
                manager.paywallsStorage.getPaywallByLocale(locale, orDefaultLocale: false, withPlacementId: placementId, withVariationId: nil)?.value,
                manager.profile.value.isTestUser
            )
        }()

        do {
            var chosen = try await httpConfigsSession.fetchUntargetedPaywallVariations(
                apiKeyPrefix: apiKeyPrefix,
                profileId: profileId,
                placementId: placementId,
                locale: locale,
                cached: cached,
                crossPlacementEligible: false,
                variationIdResolver: nil,
                disableServerCache: isTestUser,
                timeoutInterval: nil
            )

            if let manager = tryProfileManagerOrNil(with: profileId) {
                chosen = manager.paywallsStorage.savedPaywallChosen(chosen)
            }

            Adapty.trackEventIfNeed(chosen)
            return chosen.paywall

        } catch {
            guard let paywall = getCacheOrFallbackFilePaywall(
                profileId,
                placementId,
                locale,
                withCrossPlacmentABTest: false
            ) else {
                throw error.asAdaptyError ?? AdaptyError.fetchPaywallFailed(unknownError: error)
            }
            return paywall
        }
    }
}
