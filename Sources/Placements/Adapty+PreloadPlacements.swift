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
        placementIds: [String],
        loadTimeout: TimeInterval? = nil
    ) async throws(AdaptyError) {
        let placementIds = Set(placementIds.compactMap {
            let placementId = $0.trimmed
            return placementId.isEmpty ? nil : placementId
        })
        let loadTimeout = (loadTimeout ?? .defaultLoadPlacementTimeout).allowedLoadPlacementTimeout

        let logParams: EventParameters = [
            "placement_ids": placementIds
        ]

        return try await withActivatedSDK(methodName: .preloadFlows, logParams: logParams) { sdk throws(AdaptyError) in
            try await sdk.preloadPlacements(
                AdaptyFlow.self,
                placementIds: placementIds,
                loadTimeout: loadTimeout
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
                loadTimeout: .seconds(5),
                forDefaultAudience: true
            )
        }
    }

    public nonisolated static func preloadOnboardings(
        placementIds: [String],
        locale: String? = nil,
        loadTimeout: TimeInterval? = nil
    ) async throws(AdaptyError) {
        let placementIds = Set(placementIds.compactMap {
            let placementId = $0.trimmed
            return placementId.isEmpty ? nil : placementId
        })
        let locale = locale.trimmed.nonEmptyOrNil.map { AdaptyLocale($0) }
        let loadTimeout = (loadTimeout ?? .defaultLoadPlacementTimeout).allowedLoadPlacementTimeout

        let logParams: EventParameters = [
            "placement_ids": placementIds,
            "locale": locale
        ]

        return try await withActivatedSDK(methodName: .preloadOnboardings, logParams: logParams) { sdk throws(AdaptyError) in
            try await sdk.preloadPlacements(
                AdaptyOnboarding.self,
                placementIds: placementIds,
                locale: locale,
                loadTimeout: loadTimeout
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
                loadTimeout: .seconds(5),
                forDefaultAudience: true
            )
        }
    }

    private func preloadPlacements<Content: PlacementContent>(
        _ type: Content.Type,
        placementIds: Set<String>,
        locale: AdaptyLocale? = nil,
        loadTimeout: TaskDuration,
        forDefaultAudience: Bool = false
    )  async throws(AdaptyError) {
        guard placementIds.isNotEmpty else { return }

        let (userId, isTestUser) = {
            let manager = profileManager
            return (
                userId: manager?.userId ?? profileStorage.userId,
                isTestUser: manager?.isTestUser ?? false
            )
        }()

        for placementId in placementIds {
            do {
                if forDefaultAudience {
                    try await preloadPlacementForDefaultAudience(
                        type,
                        httpConfigsSession,
                        placementId,
                        locale,
                        forUserId: userId,
                        isTestUser,
                        loadTimeout: loadTimeout.asTimeInterval
                    )
                } else {
                    try await preloadPlacement(
                        type,
                        placementId,
                        locale,
                        forUserId: userId,
                        isTestUser,
                        loadTimeout: loadTimeout
                    )
                }
            } catch {
                throw error
            }
        }
    }

    private func preloadPlacement<Content: PlacementContent>(
        _ type: Content.Type,
        _ placementId: String,
        _ locale: AdaptyLocale? = nil,
        forUserId userId: AdaptyUserId,
        _ isTestUser: Bool,
        loadTimeout: TaskDuration
    )  async throws(AdaptyError) {

        var userId = userId
        var isTestUser = isTestUser

        let startTaskTime = Date()

        var fetchBackendError: AdaptyError?
        do {
            return try await withThrowingTimeout(max(loadTimeout - .milliseconds(500), .milliseconds(500))) {
                let manager = try await self.createdProfileManager
                let createdUserId = manager.userId
                isTestUser = await manager.isTestUser

                if createdUserId.isNotEqualProfileId(userId) {
                    log.verbose("fetchPlacementOrFallbackPlacement: profile changed from \(userId) to \(createdUserId)")
                    userId = createdUserId
                }

                try await self.preloadBackendPlacement(
                    type,
                    placementId,
                    locale,
                    forUserId: userId,
                    isTestUser
                )
            }

        } catch let error as AdaptyError {
            fetchBackendError =
                if error.canUseFallbackServer { nil } else { error }
        } catch {
            fetchBackendError =
                if error is TimeoutError { nil } else { .unknown(error) }
        }

        if let fetchBackendError {
            throw fetchBackendError
        }

        try await preloadPlacementForDefaultAudience(
            type,
            httpFallbackSession,
            placementId,
            locale,
            forUserId: userId,
            isTestUser,
            loadTimeout: loadTimeout.asTimeInterval + startTaskTime.timeIntervalSinceNow
        )
    }

    private func preloadBackendPlacement<Content: PlacementContent>(
        _ type: Content.Type,
        _ placementId: String,
        _ locale: AdaptyLocale?,
        forUserId userId: AdaptyUserId,
        _ isTestUser: Bool
    ) async throws(AdaptyError)  {
        var lastError: AdaptyError

        repeat {
            let crossPlacementState = await CrossPlacementStorage.state(for: userId)
            let segmentId = try profileManager(withProfileId: userId).orThrows.segmentId
            let variationId = crossPlacementState?.variationId(placementId: placementId)
            let requestWithSpecialVariation = variationId != nil

            do throws(HTTPError) {
                    if let variationId {
                        try await httpSession.preloadPlacement(
                            type,
                            apiKeyPrefix: apiKeyPrefix,
                            userId: userId,
                            placementId: placementId,
                            variationId: variationId,
                            locale: locale,
                            disableServerCache: isTestUser
                        )
                    } else {
                        try await httpSession.preloadPlacementVariations(
                            type,
                            apiKeyPrefix: apiKeyPrefix,
                            userId: userId,
                            placementId: placementId,
                            locale: locale,
                            segmentId: segmentId,
                            crossPlacementEligible: crossPlacementState?.canParticipateInABTest ?? false,
                            disableServerCache: isTestUser
                        )
                    }
                return

            } catch {
                guard !requestWithSpecialVariation else {
                    throw error.asAdaptyError
                }

                if Backend.wrongProfileSegmentId(error),
                   try await updateSegmentId(for: userId, oldSegmentId: segmentId)
                {
                    lastError = error.asAdaptyError
                    continue
                }
                throw error.asAdaptyError
            }
        } while !Task.isCancelled

        throw lastError

        func updateSegmentId(for userId: AdaptyUserId, oldSegmentId: String) async throws(AdaptyError) -> Bool {
            let manager = try profileManager(withProfileId: userId).orThrows
            guard manager.segmentId == oldSegmentId else { return true }
            return await manager.fetchSegmentId() != oldSegmentId
        }
    }

    private func preloadPlacementForDefaultAudience<Content: PlacementContent>(
        _ type: Content.Type,
        _ session: Backend.DefaultAudienceExecutor,
        _ placementId: String,
        _ locale: AdaptyLocale?,
        forUserId userId: AdaptyUserId,
        _ isTestUser: Bool,
        loadTimeout timeoutInterval: TimeInterval?
    )  async throws(AdaptyError) {
        let crossPlacementState = await CrossPlacementStorage.state(for: userId)
        let variationId = crossPlacementState?.variationId(placementId: placementId)

        do throws(HTTPError) {
            if let variationId {
                try await session.preloadPlacementForDefaultAudience(
                    type,
                    apiKeyPrefix: apiKeyPrefix,
                    placementId: placementId,
                    variationId: variationId,
                    locale: locale,
                    disableServerCache: isTestUser,
                    timeoutInterval: timeoutInterval
                )
            } else {
                try await session.preloadPlacementVariationsForDefaultAudience(
                    type,
                    apiKeyPrefix: apiKeyPrefix,
                    userId: userId,
                    placementId: placementId,
                    locale: locale,
                    disableServerCache: isTestUser,
                    timeoutInterval: timeoutInterval
                )
            }
        } catch {
            throw error.asAdaptyError
        }
    }
}
