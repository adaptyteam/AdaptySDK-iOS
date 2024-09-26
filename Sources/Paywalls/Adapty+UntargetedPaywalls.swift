//
//  Adapty+UntargetedPaywalls.swift
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
        try await getPaywallForDefaultAudience(
            placementId,
            locale: locale.map { AdaptyLocale(id: $0) } ?? .defaultPaywallLocale,
            withFetchPolicy: fetchPolicy
        )
    }

    private nonisolated static func getPaywallForDefaultAudience(
        _ placementId: String,
        locale: AdaptyLocale,
        withFetchPolicy fetchPolicy: AdaptyPaywall.FetchPolicy
    ) async throws -> AdaptyPaywall {
        try await withActivatedSDK(
            methodName: .getPaywallForDefaultAudience,
            logParams: [
                "placement_id": placementId,
                "locale": locale,
                "fetch_policy": fetchPolicy,
            ]
        ) { sdk in

            let paywall =
                if let profileManager = sdk.profileManagerOrNil {
                    try await profileManager.getUntargetedPaywall(
                        placementId,
                        locale,
                        withFetchPolicy: fetchPolicy
                    )
                } else {
                    try await sdk.getUntargetedPaywall(
                        profileManager: nil,
                        placementId,
                        locale
                    )
                }

            AdaptyUI.sendImageUrlsToObserver(paywall)
            return paywall
        }
    }

    fileprivate func getUntargetedPaywall(
        profileManager: ProfileManager?,
        _ placementId: String,
        _ locale: AdaptyLocale
    ) async throws -> AdaptyPaywall {
        let profileId = profileManager?.profileId ?? profileStorage.profileId

        do {
            let cached = profileManager?.paywallsCache.getPaywallByLocale(locale, orDefaultLocale: false, withPlacementId: placementId)?.value

            var response = try await httpConfigsSession.performFetchUntargetedPaywallVariationsRequest(
                apiKeyPrefix: apiKeyPrefix,
                profileId: profileId,
                placementId: placementId,
                locale: locale,
                cached: cached,
                disableServerCache: profileManager?.profile.value.isTestUser ?? false
            )

            if let profileManager, profileManager.isActive {
                response = profileManager.paywallsCache.savedPaywallChosen(response)
            }

            Adapty.trackEventIfNeed(response)

            return response.value
        } catch {
            if let profileManager {
                guard profileManager.isActive,
                      let value = profileManager.paywallsCache.getPaywallWithFallback(byPlacementId: placementId, locale: locale)
                else {
                    throw error.asAdaptyError ?? AdaptyError.fetchPaywallFailed(unknownError: error)
                }
                return value
            }

            if let fallback = Adapty.fallbackPaywalls?.getPaywall(byPlacementId: placementId, profileId: profileId) {
                Adapty.trackEventIfNeed(fallback)
                return fallback.value
            } else {
                throw error.asAdaptyError ?? AdaptyError.fetchPaywallFailed(unknownError: error)
            }
        }
    }
}

private extension ProfileManager {
    func getUntargetedPaywall(
        _ placementId: String,
        _ locale: AdaptyLocale,
        withFetchPolicy fetchPolicy: AdaptyPaywall.FetchPolicy
    ) async throws -> AdaptyPaywall {
        let task = Task { [weak self] in
            guard let self else { throw AdaptyError.profileWasChanged() }
            return try await Adapty.sdk.getUntargetedPaywall(
                profileManager: self,
                placementId,
                locale
            )
        }

        if let cached = paywallsCache.getPaywallByLocale(
            locale,
            orDefaultLocale: true,
            withPlacementId: placementId
        ),
            fetchPolicy.canReturn(cached) {
            return cached.value
        } else {
            return try await task.value
        }
    }
}
