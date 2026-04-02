//
//  Adapty+PlacementForDefaultAudience.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 12.08.2024
//

import AdaptyUIBuilder
import Foundation

public extension Adapty {
    /// This method enables you to retrieve the paywall from the Default Audience without having to wait for the Adapty SDK to send all the user information required for segmentation to the server.
    ///
    /// - Parameters:
    ///   - placementId: The identifier of the desired paywall. This is the value you specified when you created the paywall in the Adapty Dashboard.
    ///   - fetchPolicy: by default SDK will try to load data from server and will return cached data in case of failure. Otherwise use `.returnCacheDataElseLoad` to return cached data if it exists.
    /// - Returns: The ``AdaptyFlow`` object. This model contains the list of the products ids, paywall's identifier, custom payload, and several other properties.
    /// - Throws: An ``AdaptyError`` object
    nonisolated static func getFlowForDefaultAudience(
        placementId: String,
        fetchPolicy: AdaptyPlacementFetchPolicy = .default
    ) async throws(AdaptyError) -> AdaptyFlow {
        let placementId = placementId.trimmed
        // TODO: throw error if placementId isEmpty

        let logParams: EventParameters = [
            "placement_id": placementId,
            "fetch_policy": fetchPolicy,
        ]

        return try await withActivatedSDK(methodName: .getFlowForDefaultAudience, logParams: logParams) { sdk throws(AdaptyError) in
            let flow: AdaptyFlow = try await sdk.getPlacementForDefaultAudience(
                placementId,
                fetchPolicy
            )

            AdaptyUIBuilder.sendImageUrlsToObserver(flow)
            return flow
        }
    }

    nonisolated static func getOnboardingForDefaultAudience(
        placementId: String,
        locale: String? = nil,
        fetchPolicy: AdaptyPlacementFetchPolicy = .default
    ) async throws(AdaptyError) -> AdaptyOnboarding {
        let locale = locale.trimmed.nonEmptyOrNil.map { AdaptyLocale($0) }// ?? .defaultPlacementLocale
        let placementId = placementId.trimmed
        // TODO: throw error if placementId isEmpty

        let logParams: EventParameters = [
            "placement_id": placementId,
            "locale": locale,
            "fetch_policy": fetchPolicy,
        ]

        return try await withActivatedSDK(methodName: .getOnboardingForDefaultAudience, logParams: logParams) { sdk throws(AdaptyError) in
            let onboarding: AdaptyOnboarding = try await sdk.getPlacementForDefaultAudience(
                placementId,
                locale: locale,
                fetchPolicy
            )

            return onboarding
        }
    }

    private func getPlacementForDefaultAudience<Content: PlacementContent>(
        _ placementId: String,
        locale: AdaptyLocale? = nil,
        _ fetchPolicy: AdaptyPlacementFetchPolicy
    ) async throws(AdaptyError) -> Content {
        let manager = profileManager
        let userId = manager?.userId ?? profileStorage.userId

        async let remote = await Result.from { () async throws(AdaptyError) -> Content in
            try await self.fetchPlacementForDefaultAudience(
                userId,
                placementId,
                locale
            )
        }

        let cached: Content? = manager?
            .placementStorage
            .getPlacementById(
                placementId,
                withLocale: locale,
                orDefaultLocale: true,
                withVariationId: nil
            )?
            .withFetchPolicy(fetchPolicy)?
            .value

        if let cached {
            return cached
        } else {
            let result = await remote
            return try result.get()
        }
    }

    private func fetchPlacementForDefaultAudience<Content: PlacementContent>(
        _ userId: AdaptyUserId,
        _ placementId: String,
        _ locale: AdaptyLocale?
    ) async throws(AdaptyError) -> Content {
        let (cached, isTestUser): (Content?, Bool) = {
            guard let manager = try? profileManager(withProfileId: userId) else { return (nil, false) }
            return (
                manager.placementStorage.getPlacementById(
                    placementId,
                    withLocale: locale,
                    orDefaultLocale: false,
                    withVariationId: nil
                )?.value,
                manager.isTestUser
            )
        }()

        do {
            var chosen: AdaptyPlacementChosen<Content> = try await httpConfigsSession.fetchPlacementVariationsForDefaultAudience(
                apiKeyPrefix: apiKeyPrefix,
                userId: userId,
                placementId: placementId,
                locale: locale,
                cached: cached,
                variationIdResolver: nil,
                disableServerCache: isTestUser,
                timeoutInterval: nil
            )

            if let manager = try? profileManager(withProfileId: userId) {
                chosen = manager.placementStorage.savedPlacementChosen(chosen)
            }

            Adapty.trackEventIfNeed(chosen)
            return chosen.content

        } catch {
            guard let content: Content = getCacheOrFallbackFilePlacement(
                userId,
                placementId,
                locale,
                withCrossPlacmentABTest: false
            ) else {
                throw error.asAdaptyError
            }
            return content
        }
    }
}

