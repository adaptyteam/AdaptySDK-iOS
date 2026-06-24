//
//  Adapty+PreloadPlacements.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 17.06.2026.
//

import AdaptyUIBuilder
import Foundation

private let log = Log.default

public extension Adapty {
    nonisolated static func preloadFlows(
        placementIds: [String],
        loadTimeout: TimeInterval? = nil
    ) async throws(AdaptyError) {
        let placementIds = Set(placementIds.compactMap {
            let placementId = $0.trimmed
            return placementId.isEmpty ? nil : placementId
        })
        let loadTimeout = (loadTimeout ?? .defaultLoadPlacementTimeout).allowedLoadPlacementTimeout

        let logParams: EventParameters = [
            "placement_ids": placementIds,
        ]

        return try await withActivatedSDK(methodName: .preloadFlows, logParams: logParams) { sdk throws(AdaptyError) in
            try await sdk.preloadPlacements(
                AdaptyFlow.self,
                placementIds: placementIds,
                loadTimeout: loadTimeout
            )
        }
    }

    nonisolated static func preloadOnboardings(
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
            "locale": locale,
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

    private func preloadPlacements(
        _ type: (some PlacementContent).Type,
        placementIds: Set<String>,
        locale: AdaptyLocale? = nil,
        loadTimeout: TaskDuration
    ) async throws(AdaptyError) {
        guard placementIds.isNotEmpty else { return }

        var (userId, isTestUser) = {
            let manager = profileManager
            return (
                userId: manager?.userId ?? profileStorage.userId,
                isTestUser: manager?.isTestUser ?? false
            )
        }()

        let preloaded: [String: AdaptyError?]
        let startTaskTime = Date()

        do {
            preloaded = try await withThrowingTimeout(max(loadTimeout - .milliseconds(500), .milliseconds(500))) {
                let (createdUserId, createdIsTestUser, segmentId) = try await { @AdaptyActor in
                    let manager = try await self.createdProfileManager
                    return (
                        manager.userId,
                        manager.isTestUser,
                        manager.segmentId
                    )
                }()

                if createdUserId.isNotEqualProfileId(userId) {
                    log.verbose("preloadPlacements: profile changed from \(userId) to \(createdUserId)")
                    userId = createdUserId
                }

                isTestUser = createdIsTestUser

                return await self.preloadBackendPlacementsWithRepeatWrongSegmentId(
                    type,
                    placementIds,
                    locale,
                    segmentId,
                    userId,
                    isTestUser
                )
            }
        } catch is TimeoutError {
            preloaded = [:]
        } catch let error as AdaptyError {
            throw error
        } catch {
            throw .unknown(error)
        }

        let placementIdsForDefaultAudience = placementIds
            .filter { placementId in
                guard preloaded.keys.contains(placementId) else { return true }
                guard let adaptyError = preloaded[placementId] as? AdaptyError else { return false }
                return adaptyError.canUseFallbackServer
            }

        var preloadedForDefaultAudience: [String: AdaptyError?] = [:]
        if placementIdsForDefaultAudience.isNotEmpty {
            preloadedForDefaultAudience = await preloadBackendPlacementsForDefaultAudience(
                type,
                httpFallbackSession,
                Set(placementIdsForDefaultAudience),
                locale,
                userId,
                isTestUser,
                max(loadTimeout.asTimeInterval + startTaskTime.timeIntervalSinceNow, 0.5)
            )
        }

        let errors = preloaded.merging(preloadedForDefaultAudience, uniquingKeysWith: { _, other in
            other
        }).compactMapValues { $0 }

        if errors.isNotEmpty {
            throw PreloadPlacementsError(errors).asAdaptyError
        }
    }

    private func preloadBackendPlacementsWithRepeatWrongSegmentId(
        _ type: (some PlacementContent).Type,
        _ placementIds: Set<String>,
        _ locale: AdaptyLocale?,
        _ segmentId: String,
        _ userId: AdaptyUserId,
        _ isTestUser: Bool
    ) async -> [String: AdaptyError?] {
        guard placementIds.isNotEmpty else { return [:] }

        var segmentId = segmentId

        var results = await preloadBackendPlacements(
            type,
            placementIds,
            locale,
            segmentId,
            userId,
            isTestUser
        )

        repeat {
            let hasWrongSegmentIdError = results.values.contains {
                guard $0.option.isUseSegmentId, let error = $0.error else { return false }
                return Backend.wrongProfileSegmentId(error)
            }

            guard hasWrongSegmentIdError else { break }
            guard let manager = try? profileManager(withProfileId: userId).orThrows() else { break }
            var currentSegmentId = manager.segmentId
            if currentSegmentId == segmentId {
               let refreshedSegmentId = await manager.fetchSegmentId()
                guard refreshedSegmentId != segmentId else { break }
                currentSegmentId = refreshedSegmentId
            }

            let segmentBasedPlacementIds = Set(
                results.compactMap { $0.value.option.isUseSegmentId ? $0.key : nil }
            )

            log.verbose("preloadPlacements: segmentId changed from \(segmentId) to \(currentSegmentId), reloading \(segmentBasedPlacementIds.count) placement(s)")

            segmentId = currentSegmentId
            let reloaded = await preloadBackendPlacements(
                type,
                segmentBasedPlacementIds,
                locale,
                segmentId,
                userId,
                isTestUser
            )

            results.merge(reloaded) { _, new in new }

        } while !Task.isCancelled

        return results.mapValues { $0.error?.asAdaptyError }
    }

    private struct LoadOption: OptionSet {
        let rawValue: Int

        static let useSegmentId = LoadOption(rawValue: 1 << 0)
        static let useCrossPlacementEligible = LoadOption(rawValue: 1 << 1)

        var isUseSegmentId : Bool { contains(.useSegmentId) }
        var crossPlacementEligible : Bool { contains(.useCrossPlacementEligible) }
    }

    private func preloadBackendPlacements(
        _ type: (some PlacementContent).Type,
        _ placementIds: Set<String>,
        _ locale: AdaptyLocale?,
        _ segmentId: String,
        _ userId: AdaptyUserId,
        _ isTestUser: Bool
    ) async -> [String: (option: LoadOption, error: HTTPError?)] {
        guard placementIds.isNotEmpty else { return [:] }

        let session = httpSession
        let apiKeyPrefix = apiKeyPrefix

        return await withTaskGroup(
            of: (placementId: String, option: LoadOption, error: HTTPError?).self
        ) { group in
            let crossPlacementState = await CrossPlacementStorage.state(for: userId)
            let crossPlacementEligible = crossPlacementState?.canParticipateInABTest ?? false
            for placementId in placementIds {
                if let variationId = crossPlacementState?.variationId(placementId: placementId) {
                    group.addTask {
                        do throws(HTTPError) {
                            try await session.preloadPlacement(
                                type,
                                apiKeyPrefix: apiKeyPrefix,
                                userId: userId,
                                placementId: placementId,
                                variationId: variationId,
                                locale: locale,
                                disableServerCache: isTestUser
                            )
                            return (placementId, [], nil)
                        } catch {
                            return (placementId, [], error)
                        }
                    }
                } else {
                    group.addTask {
                        let option: LoadOption =
                        if crossPlacementEligible {
                            [.useSegmentId, .useCrossPlacementEligible]
                        } else {
                            .useSegmentId
                        }
                        do throws(HTTPError) {
                            try await session.preloadPlacementVariations(
                                type,
                                apiKeyPrefix: apiKeyPrefix,
                                userId: userId,
                                placementId: placementId,
                                locale: locale,
                                segmentId: segmentId,
                                crossPlacementEligible: crossPlacementEligible,
                                disableServerCache: isTestUser
                            )
                            return (placementId, option, nil)
                        } catch {
                            return (placementId, option, error)
                        }
                    }
                }
            }

            var result = [String: (LoadOption, HTTPError?)]()
            result.reserveCapacity(placementIds.count)
            for await (placementId, option, error) in group {
                result[placementId] = (option, error)
            }
            return result
        }
    }
}
