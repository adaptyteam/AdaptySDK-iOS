//
//  Adapty+PreloadPlacements.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 17.06.2026.
//


import AdaptyUIBuilder
import Foundation

private let log = Log.default

extension Adapty {

    public nonisolated static func preloadFlows(
        placementIds: [String]
    ) async throws(AdaptyError) {
        let placementIds = Set(placementIds.compactMap {
            let placementId = $0.trimmed
            return placementId.isEmpty ? nil : placementId
        })

        let logParams: EventParameters = [
            "placement_ids": placementIds
        ]

        return try await withActivatedSDK(methodName: .preloadFlows, logParams: logParams) { sdk throws(AdaptyError) in
            try await sdk.preloadPlacements(
                AdaptyFlow.self,
                placementIds: placementIds
            )
        }
    }

    public nonisolated static func preloadFlowsForDefaultAudience(
        placementIds: [String]
    ) async throws(AdaptyError){
        let placementIds = Set(placementIds.compactMap {
            let placementId = $0.trimmed
            return placementId.isEmpty ? nil : placementId
        })

        let logParams: EventParameters = [
            "placement_ids": placementIds
        ]

        return try await withActivatedSDK(methodName: .preloadFlowsForDefaultAudience, logParams: logParams) { sdk throws(AdaptyError) in
            try await sdk.preloadPlacements(
                AdaptyFlow.self,
                placementIds: placementIds,
                forDefaultAudience: true
            )
        }
    }

    public nonisolated static func preloadOnboardings(
        placementIds: [String],
        locale: String? = nil
    ) async throws(AdaptyError) {
        let placementIds = Set(placementIds.compactMap {
            let placementId = $0.trimmed
            return placementId.isEmpty ? nil : placementId
        })
        let locale = locale.trimmed.nonEmptyOrNil.map { AdaptyLocale($0) }

        let logParams: EventParameters = [
            "placement_ids": placementIds,
            "locale": locale
        ]

        return try await withActivatedSDK(methodName: .preloadOnboardings, logParams: logParams) { sdk throws(AdaptyError) in
            try await sdk.preloadPlacements(
                AdaptyOnboarding.self,
                placementIds: placementIds,
                locale: locale
            )
        }
    }

    public nonisolated static func preloadOnboardingsForDefaultAudience(
        placementIds: [String],
        locale: String? = nil
    ) async throws(AdaptyError){
        let placementIds = Set(placementIds.compactMap {
            let placementId = $0.trimmed
            return placementId.isEmpty ? nil : placementId
        })
        let locale = locale.trimmed.nonEmptyOrNil.map { AdaptyLocale($0) }

        let logParams: EventParameters = [
            "placement_ids": placementIds,
            "locale": locale
        ]

        return try await withActivatedSDK(methodName: .preloadOnboardingsForDefaultAudience, logParams: logParams) { sdk throws(AdaptyError) in
            try await sdk.preloadPlacements(
                AdaptyOnboarding.self,
                placementIds: placementIds,
                locale: locale,
                forDefaultAudience: true
            )
        }
    }

    private func preloadPlacements<Content: PlacementContent>(
        _ type: Content.Type,
        placementIds: Set<String>,
        locale: AdaptyLocale? = nil,
        forDefaultAudience: Bool = false
    )  async throws(AdaptyError) {
        guard placementIds.isNotEmpty else { return }

        for placementId in placementIds {
            do {
                if forDefaultAudience {
                    try await preloadPlacementForDefaultAudience(type, placementId: placementId, locale: locale)
                } else {
                    try await preloadPlacement(type, placementId: placementId, locale: locale)
                }
            } catch {
                throw error
            }
        }
    }

    private func preloadPlacement<Content: PlacementContent>(
        _ type: Content.Type,
        placementId: String,
        locale: AdaptyLocale? = nil
    )  async throws(AdaptyError) {
    }

    private func preloadPlacementForDefaultAudience<Content: PlacementContent>(
        _ type: Content.Type,
        placementId: String,
        locale: AdaptyLocale? = nil
    )  async throws(AdaptyError) {
        let (userId, isTestUser) = {
            let manager = profileManager
            return (
                userId: manager?.userId ?? profileStorage.userId,
                isTestUser: manager?.isTestUser ?? false
            )
        }()

        var lastError: AdaptyError

        repeat {
            let crossPlacementState = await CrossPlacementStorage.state(for: userId)
            let variationId = crossPlacementState?.variationId(placementId: placementId)
            let requestWithSpecialVariation = variationId != nil

            do throws(HTTPError) {
//                    if let variationId {
//                        try await httpConfigsSession.preloadPlacementForDefaultAudience(
//                            type,
//                            apiKeyPrefix: apiKeyPrefix,
//                            userId: userId,
//                            placementId: placementId,
//                            variationId: variationId,
//                            locale: locale,
//                            disableServerCache: isTestUser,
//                        )
//                    } else {
//                        try await httpConfigsSession.preloadPlacementVariationsForDefaultAudience(
//                            type,
//                            apiKeyPrefix: apiKeyPrefix,
//                            userId: userId,
//                            placementId: placementId,
//                            locale: locale,
//                            disableServerCache: isTestUser,
//                        )
//                    }
                   return
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
