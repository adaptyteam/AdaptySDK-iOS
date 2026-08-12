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
                AdaptyFlow.self,
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
            try await sdk.getPlacementForDefaultAudience(
                AdaptyOnboarding.self,
                placementId,
                locale: locale,
                fetchPolicy
            )
        }
    }

    private func getPlacementForDefaultAudience<Content: PlacementContent>(
        _ type: Content.Type,

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

        if !isTestUser, let draw = await Cache.read(
            type,
            placementId: placementId,
            locale: locale,
            fetchPolicy: fetchPolicy,
            for: userId
        ) {
            Adapty.trackEventIfNeed(draw)
            return draw.content
        }

        var lastError: AdaptyError
        do {
            let draw = try await fetchBackendPlacementForDefaultAudience(
                type,
                userId,
                isTestUser,
                placementId,
                locale
            )
            Adapty.trackEventIfNeed(draw)
            return draw.content
        } catch {
            lastError = error
        }

        if let draw = await Cache.read(
            type,
            placementId: placementId,
            locale: locale,
            fetchPolicy: .returnCacheDataElseLoad,
            for: userId,
            fallbackFile: Adapty.fallbackPlacements
        ) {
            Adapty.trackEventIfNeed(draw)
            return draw.content
        }

        throw lastError
    }

    private func fetchBackendPlacementForDefaultAudience<Content: PlacementContent>(
        _ type: Content.Type,
        _ userId: AdaptyUserId,
        _ isTestUser: Bool,
        _ placementId: String,
        _ locale: AdaptyLocale?
    ) async throws(AdaptyError) -> AdaptyPlacement.Draw<Content> {
        var lastError: AdaptyError

        repeat {
            let crossPlacementState = await CrossPlacementStorage.state(for: userId)
            let variationId = crossPlacementState?.variationId(placementId: placementId)
            if let variationId {
                do throws(HTTPError) {
                    return try await httpConfigsSession.fetchPlacementForDefaultAudience(
                        type,
                        apiKeyPrefix: apiKeyPrefix,
                        userId: userId,
                        placementId: placementId,
                        variationId: variationId,
                        locale: locale,
                        disableServerCache: isTestUser,
                        timeoutInterval: nil
                    )
                } catch {
                    throw error.asAdaptyError
                }
            } else {
                do throws(HTTPError) {
                    return try await httpConfigsSession.fetchPlacementVariationsForDefaultAudience(
                        type,
                        apiKeyPrefix: apiKeyPrefix,
                        userId: userId,
                        placementId: placementId,
                        locale: locale,
                        disableServerCache: isTestUser,
                        timeoutInterval: nil
                    )
                } catch {
                    if error.has(placementDecodingError: [.notFoundVariationId]) {
                        lastError = error.asAdaptyError
                        continue
                    } else {
                        throw error.asAdaptyError
                    }
                }
            }
        } while !Task.isCancelled

        throw lastError
    }
}

