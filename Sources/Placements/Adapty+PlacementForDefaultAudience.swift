//
//  Adapty+PlacementForDefaultAudience.swift
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
        fetchPolicy: AdaptyPlacementFetchPolicy = .default
    ) async throws -> AdaptyPaywall {
        let locale = locale.map { AdaptyLocale(id: $0) } ?? .defaultPlacementLocale

        let logParams: EventParameters = [
            "placement_id": placementId,
            "locale": locale,
            "fetch_policy": fetchPolicy,
        ]

        return try await withActivatedSDK(methodName: .getPaywallForDefaultAudience, logParams: logParams) { sdk in
            let paywall: AdaptyPaywall = try await sdk.getPlacementForDefaultAudience(
                placementId,
                locale,
                fetchPolicy
            )

            Adapty.sendImageUrlsToObserver(paywall)
            return paywall
        }
    }

    public nonisolated static func getOnboardingForDefaultAudience(
        placementId: String,
        locale: String? = nil,
        fetchPolicy: AdaptyPlacementFetchPolicy = .default
    ) async throws -> AdaptyOnboarding {
        let locale = locale.map { AdaptyLocale(id: $0) } ?? .defaultPlacementLocale

        let logParams: EventParameters = [
            "placement_id": placementId,
            "locale": locale,
            "fetch_policy": fetchPolicy,
        ]

        return try await withActivatedSDK(methodName: .getOnboardingForDefaultAudience, logParams: logParams) { sdk in
            let onboarding: AdaptyOnboarding = try await sdk.getPlacementForDefaultAudience(
                placementId,
                locale,
                fetchPolicy
            )

            return onboarding
        }
    }

    private func getPlacementForDefaultAudience<Content: AdaptyPlacementContent>(
        _ placementId: String,
        _ locale: AdaptyLocale,
        _ fetchPolicy: AdaptyPlacementFetchPolicy
    ) async throws -> Content {
        let manager = profileManager
        let profileId = manager?.profileId ?? profileStorage.profileId

        let fetchTask = Task<Content, Error> {
            try await fetchPlacementForDefaultAudience(
                profileId,
                placementId,
                locale
            )
        }

        let cached: Content? = manager?
            .placementStorage
            .getPlacementByLocale(locale, orDefaultLocale: true, withPlacementId: placementId, withVariationId: nil)?
            .withFetchPolicy(fetchPolicy)?
            .value

        let content =
            if let cached {
                cached
            } else {
                try await fetchTask.value
            }

        return content
    }

    private func fetchPlacementForDefaultAudience<Content: AdaptyPlacementContent>(
        _ profileId: String,
        _ placementId: String,
        _ locale: AdaptyLocale
    ) async throws -> Content {
        let (cached, isTestUser): (Content?, Bool) = {
            guard let manager = tryProfileManagerOrNil(with: profileId) else { return (nil, false) }
            return (
                manager.placementStorage.getPlacementByLocale(locale, orDefaultLocale: false, withPlacementId: placementId, withVariationId: nil)?.value,
                manager.profile.value.isTestUser
            )
        }()

        do {
            var chosen: AdaptyPlacementChosen<Content> = try await httpConfigsSession.fetchPlacementVariationsForDefaultAudience(
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
                chosen = manager.placementStorage.savedPlacementChosen(chosen)
            }

            Adapty.trackEventIfNeed(chosen)
            return chosen.content

        } catch {
            guard let content: Content = getCacheOrFallbackFilePlacement(
                profileId,
                placementId,
                locale,
                withCrossPlacmentABTest: false
            ) else {
                throw error.asAdaptyError ?? AdaptyError.fetchPlacementFailed(unknownError: error)
            }
            return content
        }
    }
}
