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
            try await sdk.getPlacementForDefaultAudience(
                placementId,
                fetchPolicy
            )
        }
    }

    nonisolated static func getOnboardingForDefaultAudience(
        placementId: String,
        locale: String? = nil,
        fetchPolicy: AdaptyPlacementFetchPolicy = .default
    ) async throws(AdaptyError) -> AdaptyOnboarding {
        let locale = locale.trimmed.nonEmptyOrNil.map { AdaptyLocale($0) } // ?? .defaultPlacementLocale
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
        let (userId, isTestUser) = {
            let manager = profileManager
            return (
                userId: manager?.userId ?? profileStorage.userId,
                isTestUser: manager?.isTestUser ?? false
            )
        }()

        if !isTestUser {
            if let cached: AdaptyPlacement.Draw<Content> = await Cache.read(
                placementId: placementId,
                locale: locale,
                fetchPolicy: fetchPolicy,
                for: userId
            ) {
                Adapty.trackEventIfNeed(.draw(cached))
                return cached.content
            }
        }

        do {
            return try await fetchBackendPlacementForDefaultAudience(
                userId,
                isTestUser,
                placementId,
                locale
            )
        } catch {
            if let content: Content = await fetchLocalPlacement(
                userId,
                placementId,
                locale
            )  {
                return content
            }

            throw error

        }
    }

    private func fetchBackendPlacementForDefaultAudience<Content: PlacementContent>(
        _ userId: AdaptyUserId,
        _ isTestUser: Bool,
        _ placementId: String,
        _ locale: AdaptyLocale?
    ) async throws(AdaptyError) -> Content {
        var lastError: AdaptyError

        repeat {
            let crossPlacementState = await CrossPlacementStorage.state(for: userId)
            let variationId = crossPlacementState?.variationId(placementId: placementId)
            let requestWithSpecialVariation = variationId != nil

            do throws(HTTPError) {
                let chosen: AdaptyPlacementChosen<Content> =
                    if let variationId {
                        try await httpConfigsSession.fetchPlacementForDefaultAudience(
                            apiKeyPrefix: apiKeyPrefix,
                            userId: userId,
                            placementId: placementId,
                            variationId: variationId,
                            locale: locale,
                            disableServerCache: isTestUser,
                            timeoutInterval: nil
                        )
                    } else {
                        try await httpConfigsSession.fetchPlacementVariationsForDefaultAudience(
                            apiKeyPrefix: apiKeyPrefix,
                            userId: userId,
                            placementId: placementId,
                            locale: locale,
                            disableServerCache: isTestUser,
                            timeoutInterval: nil
                        )
                    }
                Adapty.trackEventIfNeed(chosen)
                return chosen.content

            } catch {
                if !requestWithSpecialVariation,
                   error.has(placementDecodingError: [.notFoundVariationId])
                {
                    lastError = error.asAdaptyError
                    continue
                } else {
                    throw error.asAdaptyError
                }
            }
        } while !Task.isCancelled

        throw lastError
    }
}

