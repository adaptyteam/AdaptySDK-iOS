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
        let loadTimeout = (loadTimeout.map(AdaptyDuration.seconds) ?? .defaultLoadPlacementTimeout).allowedLoadPlacementTimeout
        let placementId = placementId.trimmed
        // TODO: throw error if placementId isEmpty

        let logParams: EventParameters = [
            "placement_id": placementId,
            "fetch_policy": fetchPolicy,
            "load_timeout": loadTimeout.asMilliseconds,
        ]

        return try await withActivatedSDK(methodName: .getFlow, logParams: logParams) { sdk throws(AdaptyError) in
            try await sdk.getPlacement(
                AdaptyFlow.self,
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
        let loadTimeout = (loadTimeout.map(AdaptyDuration.seconds) ?? .defaultLoadPlacementTimeout).allowedLoadPlacementTimeout
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
            try await sdk.getPlacement(
                AdaptyOnboarding.self,
                placementId: placementId,
                locale: locale,
                fetchPolicy: fetchPolicy,
                loadTimeout: loadTimeout
            )
        }
    }

    private func getPlacement<Content: PlacementContent>(
        _ type: Content.Type,
        placementId: String,
        locale: AdaptyLocale? = nil,
        fetchPolicy: AdaptyPlacementFetchPolicy,
        loadTimeout: AdaptyDuration
    ) async throws(AdaptyError) -> Content {
        var (userId, isTestUser) = {
            let manager = profileManager
            return (
                userId: manager?.userId ?? profileStorage.userId,
                isTestUser: manager?.isTestUser ?? false
            )
        }()

        let startTaskTime = AdaptyContinuousClock.now

        var lastError: AdaptyError
        let canUseFallbackServer: Bool
        do {
            return try await withThrowingTimeout(max(loadTimeout - .milliseconds(500), .milliseconds(500))) {
                let manager = try await self.createdProfileManager
                let createdUserId = manager.userId
                isTestUser = await manager.isTestUser

                if createdUserId.isNotEqualProfileId(userId) {
                    log.verbose("fetchPlacementOrFallbackPlacement: profile changed from \(userId) to \(createdUserId)")
                    userId = createdUserId
                }

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

                let draw = try await self.fetchBackendPlacement(
                    type,
                    placementId,
                    locale,
                    forUserId: userId,
                    isTestUser
                )
                Adapty.trackEventIfNeed(draw)
                return draw.content
            }
        } catch let error as AdaptyError {
            if error.isProfileWasChanged {
                throw error
            }
            lastError = error
            canUseFallbackServer = error.canUseFallbackServer
        } catch {
            lastError = .unknown(error)
            canUseFallbackServer = error is TimeoutError
        }

        if let draw = await Cache.read(
            type,
            placementId: placementId,
            locale: locale,
            fetchPolicy: .returnCacheDataElseLoad,
            for: userId
        ) {
            Adapty.trackEventIfNeed(draw)
            return draw.content
        }

        if canUseFallbackServer {
            do throws(AdaptyError) {
                let draw = try await fetchFallbackBackendPlacement(
                    type,
                    placementId,
                    locale,
                    forUserId: userId,
                    isTestUser,
                    withTimeout: loadTimeout - (AdaptyContinuousClock.now - startTaskTime)
                )
                Adapty.trackEventIfNeed(draw)
                return draw.content
            } catch {
                if error.isProfileWasChanged {
                    throw error
                }
                lastError = error
            }
        }

        if let draw = await Adapty.fallbackPlacements?.read(
            type,
            placementId: placementId,
            locale: locale,
            for: userId
        ) {
            Adapty.trackEventIfNeed(draw)
            return draw.content
        }

        throw lastError
    }

    private func fetchBackendPlacement<Content: PlacementContent>(
        _ type: Content.Type,
        _ placementId: String,
        _ locale: AdaptyLocale?,
        forUserId userId: AdaptyUserId,
        _ isTestUser: Bool
    ) async throws(AdaptyError) -> AdaptyPlacement.Draw<Content> {
        var lastError: AdaptyError
        repeat {
            let crossPlacementState = await CrossPlacementStorage.state(for: userId)
            let segmentId = try profileManager(withProfileId: userId).orThrows().segmentId
            let variationId = crossPlacementState?.variationId(placementId: placementId)
            let requestWithSpecialVariation = variationId != nil

            do throws(HTTPError) {
                return if let variationId {
                    try await httpSession.fetchPlacement(
                        type,
                        apiKeyPrefix: apiKeyPrefix,
                        userId: userId,
                        placementId: placementId,
                        variationId: variationId,
                        locale: locale,
                        disableServerCache: isTestUser
                    )
                } else {
                    try await httpSession.fetchPlacementVariations(
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

    private func fetchFallbackBackendPlacement<Content: PlacementContent>(
        _ type: Content.Type,
        _ placementId: String,
        _ locale: AdaptyLocale?,
        forUserId userId: AdaptyUserId,
        _ isTestUser: Bool,
        withTimeout timeoutInterval: AdaptyDuration?
    ) async throws(AdaptyError) -> AdaptyPlacement.Draw<Content> {
        var lastError: AdaptyError
        repeat {
            let crossPlacementState = await CrossPlacementStorage.state(for: userId)
            let variationId = crossPlacementState?.variationId(placementId: placementId)
            let requestWithSpecialVariation = variationId != nil

            do throws(HTTPError) {
                return if let variationId {
                    try await httpFallbackSession.fetchPlacementForDefaultAudience(
                        type,
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
extension AdaptyDuration {
    static let defaultLoadPlacementTimeout: AdaptyDuration = .seconds(5)
    static let minimumLoadPaywallTimeout: AdaptyDuration = .seconds(1)

    var allowedLoadPlacementTimeout: AdaptyDuration {
        let minimum: AdaptyDuration = .minimumLoadPaywallTimeout
        guard self < minimum else { return self }
        log.warn("The  paywall load timeout parameter cannot be less than \(minimum.asTimeInterval)s")
        return minimum
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
