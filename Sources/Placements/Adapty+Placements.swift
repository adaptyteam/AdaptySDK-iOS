//
//  Adapty+Placements.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 01.11.2023
//

import AdaptyUIBuilder
import Foundation

private let log = Log.default

extension Adapty {
    /// Adapty allows you remotely configure the products that will be displayed in your app. This way you don't have to hardcode the products and can dynamically change offers or run A/B tests without app releases.
    ///
    /// Read more on the [Adapty Documentation](https://docs.adapty.io/v2.0.0/docs/displaying-products)
    ///
    /// - Parameters:
    ///   - placementId: The identifier of the desired paywall. This is the value you specified when you created the paywall in the Adapty Dashboard.
    ///   - fetchPolicy: by default SDK will try to load data from server and will return cached data in case of failure. Otherwise use `.returnCacheDataElseLoad` to return cached data if it exists.
    /// - Returns: The ``AdaptyFlow`` object. This model contains the list of the products ids, paywall's identifier, custom payload, and several other properties.
    /// - Throws: An ``AdaptyError`` object
    public nonisolated static func getFlow(
        placementId: String,
        fetchPolicy: AdaptyPlacementFetchPolicy = .default,
        loadTimeout: TimeInterval? = nil
    ) async throws(AdaptyError) -> AdaptyFlow {
        let loadTimeout = (loadTimeout ?? .defaultLoadPlacementTimeout).allowedLoadPlacementTimeout
        let placementId = placementId.trimmed
        // TODO: throw error if placementId isEmpty

        let logParams: EventParameters = [
            "placement_id": placementId,
            "fetch_policy": fetchPolicy,
            "load_timeout": loadTimeout.asMilliseconds,
        ]

        return try await withActivatedSDK(methodName: .getFlow, logParams: logParams) { sdk throws(AdaptyError) in
            try await sdk.getPlacement(
                placementId: placementId,
                fetchPolicy: fetchPolicy,
                loadTimeout: loadTimeout
            )
        }
    }

    public nonisolated static func getOnboarding(
        placementId: String,
        locale: String? = nil,
        fetchPolicy: AdaptyPlacementFetchPolicy = .default,
        loadTimeout: TimeInterval? = nil
    ) async throws(AdaptyError) -> AdaptyOnboarding {
        let loadTimeout = (loadTimeout ?? .defaultLoadPlacementTimeout).allowedLoadPlacementTimeout
        let locale = locale.trimmed.nonEmptyOrNil.map { AdaptyLocale($0) } ?? .defaultPlacementLocale
        let placementId = placementId.trimmed
        // TODO: throw error if placementId isEmpty

        let logParams: EventParameters = [
            "placement_id": placementId,
            "locale": locale,
            "fetch_policy": fetchPolicy,
            "load_timeout": loadTimeout.asMilliseconds,
        ]

        return try await withActivatedSDK(methodName: .getOnboarding, logParams: logParams) { sdk throws(AdaptyError) in
            let onboarding: AdaptyOnboarding = try await sdk.getPlacement(
                placementId: placementId,
                locale: locale,
                fetchPolicy: fetchPolicy,
                loadTimeout: loadTimeout
            )

            return onboarding
        }
    }

    private func getPlacement<Content: PlacementContent>(
        placementId: String,
        locale: AdaptyLocale? = nil,
        fetchPolicy: AdaptyPlacementFetchPolicy,
        loadTimeout: TaskDuration
    ) async throws(AdaptyError) -> Content {
        var (userId, isTestUser) = {
            let manager = profileManager
            return (
                userId: manager?.userId ?? profileStorage.userId,
                isTestUser: manager?.isTestUser ?? false
            )
        }()

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

                return try await self.fetchBackendPlacement(
                    placementId,
                    locale,
                    withPolicy: fetchPolicy,
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

        do throws(AdaptyError) {
            if let fetchBackendError {
                throw fetchBackendError
            }
            return try await fetchFallbackBackendPlacement(
                placementId,
                locale,
                forUserId: userId,
                isTestUser,
                withTimeout: loadTimeout.asTimeInterval + startTaskTime.timeIntervalSinceNow
            )

        } catch {
            if error.isProfileWasChanged { throw error }
            if let content: Content = await fetchLocalPlacement(
                userId,
                placementId,
                locale
            ) {
                return content
            } else {
                throw error
            }
        }
    }

    private func fetchBackendPlacement<Content: PlacementContent>(
        _ placementId: String,
        _ locale: AdaptyLocale?,
        withPolicy fetchPolicy: AdaptyPlacementFetchPolicy,
        forUserId userId: AdaptyUserId,
        _ isTestUser: Bool
    ) async throws(AdaptyError) -> Content {
        if !isTestUser {
            if let draw: AdaptyPlacement.Draw<Content> = await Cache.read(
                placementId: placementId,
                locale: locale,
                fetchPolicy: fetchPolicy,
                for: userId
            ) {
                Adapty.trackEventIfNeed(draw)
                return draw.content
            }
        }

        var lastError: AdaptyError

        repeat {
            let crossPlacementState = await CrossPlacementStorage.state(for: userId)
            let segmentId = try profileManager(withProfileId: userId).orThrows().segmentId
            let variationId = crossPlacementState?.variationId(placementId: placementId)
            let requestWithSpecialVariation = variationId != nil

            do throws(HTTPError) {
                let draw: AdaptyPlacement.Draw<Content> =
                    if let variationId {
                        try await httpSession.fetchPlacement(
                            Content.self,
                            apiKeyPrefix: apiKeyPrefix,
                            userId: userId,
                            placementId: placementId,
                            variationId: variationId,
                            locale: locale,
                            disableServerCache: isTestUser
                        )
                    } else {
                        try await httpSession.fetchPlacementVariations(
                            Content.self,
                            apiKeyPrefix: apiKeyPrefix,
                            userId: userId,
                            placementId: placementId,
                            locale: locale,
                            segmentId: segmentId,
                            crossPlacementEligible: crossPlacementState?.canParticipateInABTest ?? false,
                            disableServerCache: isTestUser
                        )
                    }
                Adapty.trackEventIfNeed(draw)
                return draw.content

            } catch {
                guard !requestWithSpecialVariation else {
                    throw error.asAdaptyError
                }

                if error.has(placementDecodingError: [.notFoundVariationId]) {
                    lastError = error.asAdaptyError
                    continue
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
            let manager = try profileManager(withProfileId: userId).orThrows()
            guard manager.segmentId == oldSegmentId else { return true }
            return await manager.fetchSegmentId() != oldSegmentId
        }
    }

    func fetchLocalPlacement<Content: PlacementContent>(
        _ userId: AdaptyUserId,
        _ placementId: String,
        _ locale: AdaptyLocale?
    ) async -> Content? {
        // TODO: need implement (Search in Fallback)
        if let draw: AdaptyPlacement.Draw<Content> = await Cache.read(
            placementId: placementId,
            locale: locale,
            fetchPolicy: .returnCacheDataElseLoad,
            for: userId
        ) {
            Adapty.trackEventIfNeed(draw)
            return draw.content
        }
        return nil

//        let crossPlacementState = await CrossPlacementStorage.state(for: userId)
//
//
//        let chosen: AdaptyPlacementChosen<Content>? =
//            if let manager = try? profileManager(withProfileId: userId) {
//                manager.placementStorage.getPlacementWithFallback(
//                    byPlacementId: placementId,
//                    withVariationId: withCrossPlacmentABTest ? manager.crossPlacmentStorage.state?.variationId(placementId: placementId) : nil,
//                    userId: userId,
//                    locale: locale
//                )
//            } else {
//                try? Adapty.fallbackPlacements?.getPlacement(
//                    byPlacementId: placementId,
//                    withVariationId: nil,
//                    userId: userId,
//                    requestLocale: locale
//                )
//            }
//
//        guard let chosen else { return nil }
//
//        Adapty.trackEventIfNeed(chosen)
//        return chosen.content
    }

    private func fetchFallbackBackendPlacement<Content: PlacementContent>(
        _ placementId: String,
        _ locale: AdaptyLocale?,
        forUserId userId: AdaptyUserId,
        _ isTestUser: Bool,
        withTimeout timeoutInterval: TimeInterval?
    ) async throws(AdaptyError) -> Content {
        var lastError: AdaptyError
        repeat {
            let crossPlacementState = await CrossPlacementStorage.state(for: userId)
            let variationId = crossPlacementState?.variationId(placementId: placementId)
            let requestWithSpecialVariation = variationId != nil

            do throws(HTTPError) {
                let draw: AdaptyPlacement.Draw<Content> =
                    if let variationId {
                        try await httpFallbackSession.fetchPlacementForDefaultAudience(
                            Content.self,
                            apiKeyPrefix: apiKeyPrefix,
                            userId: userId,
                            placementId: placementId,
                            variationId: variationId,
                            locale: locale,
                            disableServerCache: isTestUser,
                            timeoutInterval: timeoutInterval
                        )
                    } else {
                        try await httpFallbackSession.fetchPlacementVariationsForDefaultAudience(
                            Content.self,
                            apiKeyPrefix: apiKeyPrefix,
                            userId: userId,
                            placementId: placementId,
                            locale: locale,
                            disableServerCache: isTestUser,
                            timeoutInterval: timeoutInterval
                        )
                    }
                Adapty.trackEventIfNeed(draw)
                return draw.content

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

extension TimeInterval {
    static let defaultLoadPlacementTimeout: TimeInterval = 5.0
    static let minimumLoadPaywallTimeout: TimeInterval = 1.0

    var allowedLoadPlacementTimeout: TaskDuration {
        let minimum: TimeInterval = .minimumLoadPaywallTimeout
        guard self < minimum else { return TaskDuration(self) }
        log.warn("The  paywall load timeout parameter cannot be less than \(minimum)s")
        return TaskDuration(minimum)
    }
}

extension AdaptyError {
    var canUseFallbackServer: Bool {
        if let error = wrapped as? HTTPError,
           Backend.canUseFallbackServer(error)
        {
            true
        } else {
            false
        }
    }

    var isProfileWasChanged: Bool {
        if let error = wrapped as? InternalAdaptyError,
           case .profileWasChanged = error
        {
            true
        } else {
            false
        }
    }
}

