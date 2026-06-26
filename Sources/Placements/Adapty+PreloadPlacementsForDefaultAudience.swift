//
//  Adapty+PreloadPlacementsForDefaultAudience.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 17.06.2026.
//

import AdaptyUIBuilder
import Foundation

private let log = Log.default

public extension Adapty {
    nonisolated static func preloadFlowsForDefaultAudience(
        placementIds: [String]
    ) async throws(AdaptyError) {
        let placementIds = Set(placementIds.compactMap {
            let placementId = $0.trimmed
            return placementId.isEmpty ? nil : placementId
        })

        let logParams: EventParameters = [
            "placement_ids": placementIds,
        ]

        return try await withActivatedSDK(methodName: .preloadFlowsForDefaultAudience, logParams: logParams) { sdk throws(AdaptyError) in
            try await sdk.preloadPlacementsForDefaultAudience(
                AdaptyFlow.self,
                sdk.httpConfigsSession,
                placementIds: placementIds
            )
        }
    }

    nonisolated static func preloadOnboardingsForDefaultAudience(
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
            "locale": locale,
        ]

        return try await withActivatedSDK(methodName: .preloadOnboardingsForDefaultAudience, logParams: logParams) { sdk throws(AdaptyError) in
            try await sdk.preloadPlacementsForDefaultAudience(
                AdaptyOnboarding.self,
                sdk.httpConfigsSession,
                placementIds: placementIds,
                locale: locale
            )
        }
    }

    private func preloadPlacementsForDefaultAudience(
        _ type: (some PlacementContent).Type,
        _ session: Backend.DefaultAudienceExecutor,
        placementIds: Set<String>,
        locale: AdaptyLocale? = nil
    ) async throws(AdaptyError) {
        guard placementIds.isNotEmpty else { return }

        let (userId, isTestUser) = {
            let manager = profileManager
            return (
                userId: manager?.userId ?? profileStorage.userId,
                isTestUser: manager?.isTestUser ?? false
            )
        }()

        let errors = await preloadBackendPlacementsForDefaultAudience(
            type,
            session,
            placementIds,
            locale,
            userId,
            isTestUser
        ).compactMapValues { $0?.asAdaptyError }

        if errors.isNotEmpty {
            throw PreloadPlacementsError(errors).asAdaptyError
        }
    }

    internal func preloadBackendPlacementsForDefaultAudience(
        _ type: (some PlacementContent).Type,
        _ session: Backend.DefaultAudienceExecutor,
        _ placementIds: Set<String>,
        _ locale: AdaptyLocale?,
        _ userId: AdaptyUserId,
        _ isTestUser: Bool,
        _ timeoutInterval: TimeInterval? = nil
    ) async -> [String: HTTPError?] {
        guard placementIds.isNotEmpty else { return [:] }
        let apiKeyPrefix = apiKeyPrefix

        return await withTaskGroup(
            of: (placementId: String, error: HTTPError?).self
        ) { group in
            let crossPlacementState = await CrossPlacementStorage.state(for: userId)
            for placementId in placementIds {
                if let variationId = crossPlacementState?.variationId(placementId: placementId) {
                    group.addTask {
                        do throws(HTTPError) {
                            try await session.preloadPlacementForDefaultAudience(
                                type,
                                apiKeyPrefix: apiKeyPrefix,
                                placementId: placementId,
                                variationId: variationId,
                                locale: locale,
                                disableServerCache: isTestUser,
                                timeoutInterval: timeoutInterval
                            )
                            return (placementId, nil)
                        } catch {
                            return (placementId, error)
                        }
                    }
                } else {
                    group.addTask {
                        do throws(HTTPError) {
                            try await session.preloadPlacementVariationsForDefaultAudience(
                                type,
                                apiKeyPrefix: apiKeyPrefix,
                                userId: userId,
                                placementId: placementId,
                                locale: locale,
                                disableServerCache: isTestUser,
                                timeoutInterval: timeoutInterval
                            )
                            return (placementId, nil)
                        } catch {
                            return (placementId, error)
                        }
                    }
                }
            }

            var result = [String: HTTPError?]()
            result.reserveCapacity(placementIds.count)
            for await (placementId, error) in group {
                result[placementId] = error
            }
            return result
        }
    }
}
