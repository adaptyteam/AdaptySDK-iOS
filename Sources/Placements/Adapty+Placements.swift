//
//  Adapty+Paywalls.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 01.11.2023
//

import Foundation

private let log = Log.default

extension Adapty {
    /// Adapty allows you remotely configure the products that will be displayed in your app. This way you don't have to hardcode the products and can dynamically change offers or run A/B tests without app releases.
    ///
    /// Read more on the [Adapty Documentation](https://docs.adapty.io/v2.0.0/docs/displaying-products)
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
    public nonisolated static func getPaywall(
        placementId: String,
        locale: String? = nil,
        fetchPolicy: AdaptyPlacementFetchPolicy = .default,
        loadTimeout: TimeInterval? = nil
    ) async throws -> AdaptyPaywall {
        let loadTimeout = (loadTimeout ?? .defaultLoadPlacementTimeout).allowedLoadPlacementTimeout
        let locale = locale.map { AdaptyLocale(id: $0) } ?? .defaultPlacementLocale

        let logParams: EventParameters = [
            "placement_id": placementId,
            "locale": locale,
            "fetch_policy": fetchPolicy,
            "load_timeout": loadTimeout.asMilliseconds,
        ]

        return try await withActivatedSDK(methodName: .getPaywall, logParams: logParams) { sdk in
            let paywall: AdaptyPaywall = try await sdk.getPlacement(
                placementId,
                locale,
                fetchPolicy,
                loadTimeout
            )
            Adapty.sendImageUrlsToObserver(paywall)

            return paywall
        }
    }

    public nonisolated static func getOnboarding(
        placementId: String,
        locale: String? = nil,
        fetchPolicy: AdaptyPlacementFetchPolicy = .default,
        loadTimeout: TimeInterval? = nil
    ) async throws -> AdaptyOnboarding {
        let loadTimeout = (loadTimeout ?? .defaultLoadPlacementTimeout).allowedLoadPlacementTimeout
        let locale = locale.map { AdaptyLocale(id: $0) } ?? .defaultPlacementLocale

        let logParams: EventParameters = [
            "placement_id": placementId,
            "locale": locale,
            "fetch_policy": fetchPolicy,
            "load_timeout": loadTimeout.asMilliseconds,
        ]

        return try await withActivatedSDK(methodName: .getOnboarding, logParams: logParams) { sdk in
            let onboarding: AdaptyOnboarding = try await sdk.getPlacement(
                placementId,
                locale,
                fetchPolicy,
                loadTimeout
            )

            return onboarding
        }
    }

    private func getPlacement<Content: AdaptyPlacementContent>(
        _ placementId: String,
        _ locale: AdaptyLocale,
        _ fetchPolicy: AdaptyPlacementFetchPolicy,
        _ loadTimeout: TaskDuration
    ) async throws -> Content {
        let profileId = profileStorage.profileId

        do {
            let startTaskTime = Date()

            do {
                return try await withThrowingTimeout(loadTimeout - .milliseconds(500)) {
                    try await self.fetchPlacement(
                        profileId,
                        placementId,
                        locale,
                        fetchPolicy
                    )
                }
            } catch let error where error.canUseFallbackServer {
                return try await fetchFallbackPlacement(
                    profileId,
                    placementId,
                    locale,
                    loadTimeout.asTimeInterval + startTaskTime.timeIntervalSinceNow
                )
            }

        } catch {
            guard let content: Content = getCacheOrFallbackFilePlacement(
                profileId,
                placementId,
                locale,
                withCrossPlacmentABTest: true
            )
            else {
                throw error.asAdaptyError ?? AdaptyError.fetchPlacementFailed(unknownError: error)
            }

            return content
        }
    }

    private func fetchPlacement<Content: AdaptyPlacementContent>(
        _ profileId: String,
        _ placementId: String,
        _ locale: AdaptyLocale,
        _ fetchPolicy: AdaptyPlacementFetchPolicy
    ) async throws -> Content {
        let manager = try await createdProfileManager

        guard manager.profileId == profileId else {
            throw AdaptyError.profileWasChanged()
        }

        let fetchTask = Task<Content, Error> {
            try await fetchPlacement(
                profileId,
                placementId,
                locale
            )
        }

        let cached: Content? = manager
            .placementStorage
            .getPlacementByLocale(locale,
                                  orDefaultLocale: true,
                                  withPlacementId: placementId,
                                  withVariationId: manager.storage.crossPlacementState?.variationId(placementId: placementId))?
            .withFetchPolicy(fetchPolicy)?
            .value

        let content =
            if let cached {
                cached
            } else {
                try await withTaskCancellationHandler {
                    try await fetchTask.value
                } onCancel: {
                    fetchTask.cancel()
                }
            }

        return content
    }

    private func fetchPlacement<Content: AdaptyPlacementContent>(
        _ profileId: String,
        _ placementId: String,
        _ locale: AdaptyLocale
    ) async throws -> Content {
        while true {
            let (segmentId, cached, isTestUser, crossPlacementState, variationId) = try {
                let manager = try profileManager(with: profileId).orThrows
                let crossPlacementState = manager.storage.crossPlacementState
                let variationId = crossPlacementState?.variationId(placementId: placementId)
                let cached: Content? = manager.placementStorage
                    .getPlacementByLocale(
                        locale,
                        orDefaultLocale: false,
                        withPlacementId: placementId,
                        withVariationId: variationId
                    )?
                    .value
                return (
                    manager.profile.value.segmentId,
                    cached,
                    manager.profile.value.isTestUser,
                    crossPlacementState,
                    variationId
                )
            }()

            let caseWithPaywallVariation = variationId != nil

            do {
                var chosen: AdaptyPlacementChosen<Content>

                if let variationId {
                    chosen = try await httpSession.fetchPlacement(
                        apiKeyPrefix: apiKeyPrefix,
                        profileId: profileId,
                        placementId: placementId,
                        variationId: variationId,
                        locale: locale,
                        cached: cached,
                        disableServerCache: isTestUser
                    )
                } else if let crossPlacementState, crossPlacementState.canParticipateInABTest {
                    chosen = try await httpSession.fetchPlacementVariations(
                        apiKeyPrefix: apiKeyPrefix,
                        profileId: profileId,
                        placementId: placementId,
                        locale: locale,
                        segmentId: segmentId,
                        cached: cached,
                        crossPlacementEligible: true,
                        variationIdResolver: { @AdaptyActor placementId, draw in
                            guard let manager = self.tryProfileManagerOrNil(with: draw.profileId) else {
                                Log.crossAB.verbose("Cross-AB-test placementId = \(placementId), error = PROFILE_WAS_CHANGED")
                                throw ResponseDecodingError.profileWasChanged
                            }

                            guard let crossPlacementState = manager.storage.crossPlacementState else {
                                // We are prohibited from participating in Cross AB Tests
                                if draw.participatesInCrossPlacementABTest {
                                    Log.crossAB.verbose("Cross-AB-test placementId = \(placementId), DISABLED -> repeat")
                                    throw ResponseDecodingError.crossPlacementABTestDisabled
                                } else {
                                    Log.crossAB.verbose("Cross-AB-test placementId = \(placementId), DISABLED -> variationId = \(draw.content.variationId) DRAW")
                                    return draw.content.variationId
                                }
                            }

                            if crossPlacementState.canParticipateInABTest {
                                if draw.participatesInCrossPlacementABTest {
                                    Log.crossAB.verbose("Cross-AB-test placementId = \(placementId), BEGIN    -> variationId = \(draw.content.variationId), state = \(draw.variationIdByPlacements) DRAW")
                                    manager.storage.setCrossPlacementState(.init(
                                        variationIdByPlacements: draw.variationIdByPlacements,
                                        version: crossPlacementState.version
                                    ))
                                } else {
                                    Log.crossAB.verbose("Cross-AB-test placementId = \(placementId), BEGIN-NO-CROSS -> variationId = \(draw.content.variationId) DRAW")
                                }
                                return draw.content.variationId
                            } else if let variationId = manager.storage.crossPlacementState?.variationId(placementId: placementId) {
                                // We are participating in cross AB test: A
                                // And the paywall is from cross AB test: A
                                Log.crossAB.verbose("Cross-AB-test placementId = \(placementId), CONTINUE -> variationId = \(variationId)")
                                return variationId
                            } else if !draw.participatesInCrossPlacementABTest {
                                // We are participating in cross AB test: A
                                // But the paywall is not in any cross AB test
                                Log.crossAB.verbose("Cross-AB-test placementId = \(placementId), CONTINUE-NO-CROSS -> variationId = \(draw.content.variationId) DRAW")
                                return draw.content.variationId
                            } else {
                                // We are participating in cross AB test: A
                                // But the paywall is from cross AB test: B
                                Log.crossAB.verbose("Cross-AB-test placementId = \(placementId), CONTINUE-OTHER-CROSS -> variationId = \(draw.content.variationId) DRAW")
                                return draw.content.variationId
                            }

                        },
                        disableServerCache: isTestUser
                    )
                } else {
                    chosen = try await httpSession.fetchPlacementVariations(
                        apiKeyPrefix: apiKeyPrefix,
                        profileId: profileId,
                        placementId: placementId,
                        locale: locale,
                        segmentId: segmentId,
                        cached: cached,
                        crossPlacementEligible: false,
                        variationIdResolver: nil,
                        disableServerCache: isTestUser
                    )
                }

                if let manager = tryProfileManagerOrNil(with: profileId) {
                    chosen = manager.placementStorage.savedPlacementChosen(chosen)
                }

                Adapty.trackEventIfNeed(chosen)
                return chosen.content

            } catch {
                if error.responseDecodingError([.profileWasChanged]) {
                    throw AdaptyError.profileWasChanged()
                }

                guard !caseWithPaywallVariation else {
                    throw error.asAdaptyError ?? AdaptyError.fetchPlacementFailed(unknownError: error)
                }

                if error.responseDecodingError([.notFoundVariationId, .crossPlacementABTestDisabled]) { continue }

                guard error.wrongProfileSegmentId,
                      try await updateSegmentId(for: profileId, oldSegmentId: segmentId)
                else {
                    throw error.asAdaptyError ?? AdaptyError.fetchPlacementFailed(unknownError: error)
                }
            }
        }

        func updateSegmentId(for profileId: String, oldSegmentId: String) async throws -> Bool {
            let manager = try profileManager(with: profileId).orThrows
            guard manager.profile.value.segmentId == oldSegmentId else { return true }
            return await manager.getProfile().segmentId != oldSegmentId
        }
    }

    func getCacheOrFallbackFilePlacement<Content: AdaptyPlacementContent>(
        _ profileId: String,
        _ placementId: String,
        _ locale: AdaptyLocale,
        withCrossPlacmentABTest: Bool
    ) -> Content? {
        let chosen: AdaptyPlacementChosen<Content>? =
            if let manager = tryProfileManagerOrNil(with: profileId) {
                manager.placementStorage.getPlacementWithFallback(
                    byPlacementId: placementId,
                    withVariationId: withCrossPlacmentABTest ? manager.storage.crossPlacementState?.variationId(placementId: placementId) : nil,
                    profileId: profileId,
                    locale: locale
                )
            } else {
                Adapty.fallbackPlacements?.getPlacement(
                    byPlacementId: placementId,
                    withVariationId: nil,
                    profileId: profileId
                )
            }

        guard let chosen else { return nil }

        Adapty.trackEventIfNeed(chosen)
        return chosen.content
    }

    private func fetchFallbackPlacement<Content: AdaptyPlacementContent>(
        _ profileId: String,
        _ placementId: String,
        _ locale: AdaptyLocale,
        _ timeoutInterval: TimeInterval?
    ) async throws -> Content {
        while true {
            let (cached, isTestUser, variationId): (Content?, Bool, String?) = {
                guard let manager = tryProfileManagerOrNil(with: profileId) else { return (nil, false, nil) }
                let variationId = manager.storage.crossPlacementState?.variationId(placementId: placementId)
                return (
                    manager.placementStorage.getPlacementByLocale(locale, orDefaultLocale: false, withPlacementId: placementId, withVariationId: variationId)?.value,
                    manager.profile.value.isTestUser,
                    variationId
                )
            }()

            do {
                var chosen: AdaptyPlacementChosen<Content> = if let variationId {
                    try await httpFallbackSession.fetchFallbackPlacement(
                        apiKeyPrefix: apiKeyPrefix,
                        profileId: profileId,
                        placementId: placementId,
                        paywallVariationId: variationId,
                        locale: locale,
                        cached: nil,
                        disableServerCache: isTestUser,
                        timeoutInterval: timeoutInterval
                    )
                } else {
                    try await httpFallbackSession.fetchFallbackPlacementVariations(
                        apiKeyPrefix: apiKeyPrefix,
                        profileId: profileId,
                        placementId: placementId,
                        locale: locale,
                        cached: cached,
                        crossPlacementEligible: false,
                        variationIdResolver: nil,
                        disableServerCache: isTestUser,
                        timeoutInterval: timeoutInterval
                    )
                }

                if let manager = tryProfileManagerOrNil(with: profileId) {
                    chosen = manager.placementStorage.savedPlacementChosen(chosen)
                }

                Adapty.trackEventIfNeed(chosen)
                return chosen.content

            } catch {
                guard error.responseDecodingError([.notFoundVariationId]) else { throw error }
            }
        }
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

private extension Error {
    var canUseFallbackServer: Bool {
        let error = unwrapped
        if error is TimeoutError { return true }
        if let httpError = error as? HTTPError { return Backend.canUseFallbackServer(httpError) }
        return false
    }

    var wrongProfileSegmentId: Bool {
        let error = unwrapped
        if let httpError = error as? HTTPError { return Backend.wrongProfileSegmentId(httpError) }
        return false
    }

    var wrongPlacementContentType: Bool {
        let error = unwrapped
        if let httpError = error as? HTTPError { return Backend.wrongPlacementContentType(httpError) }
        return false
    }

    func responseDecodingError(_ decodingError: Set<ResponseDecodingError>) -> Bool {
        let error = unwrapped
        if let httpError = error as? HTTPError { return Backend.responseDecodingError(decodingError, httpError) }
        return false
    }
}
