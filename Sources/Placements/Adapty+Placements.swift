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
    ) async throws(AdaptyError) -> AdaptyPaywall {
        let loadTimeout = (loadTimeout ?? .defaultLoadPlacementTimeout).allowedLoadPlacementTimeout
        let locale = locale.trimmed.nonEmptyOrNil.map { AdaptyLocale(id: $0) } ?? .defaultPlacementLocale
        let placementId = placementId.trimmed
        // TODO: throw error if placementId isEmpty

        let logParams: EventParameters = [
            "placement_id": placementId,
            "locale": locale,
            "fetch_policy": fetchPolicy,
            "load_timeout": loadTimeout.asMilliseconds,
        ]

        return try await withActivatedSDK(methodName: .getPaywall, logParams: logParams) { sdk throws(AdaptyError) in
            let paywall: AdaptyPaywall = try await sdk.getPlacement(
                placementId: placementId,
                locale: locale,
                fetchPolicy: fetchPolicy,
                loadTimeout: loadTimeout
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
    ) async throws(AdaptyError) -> AdaptyOnboarding {
        let loadTimeout = (loadTimeout ?? .defaultLoadPlacementTimeout).allowedLoadPlacementTimeout
        let locale = locale.trimmed.nonEmptyOrNil.map { AdaptyLocale(id: $0) } ?? .defaultPlacementLocale
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

    private func getPlacement<Content: AdaptyPlacementContent>(
        placementId: String,
        locale: AdaptyLocale,
        fetchPolicy: AdaptyPlacementFetchPolicy,
        loadTimeout: TaskDuration
    ) async throws(AdaptyError) -> Content {
        do {
            return try await fetchPlacementOrFallbackPlacement(
                placementId,
                locale,
                fetchPolicy,
                loadTimeout
            )
        } catch {
            if error.isProfileWasChanged { throw error }

            if let content: Content = getCacheOrFallbackFilePlacement(
                profileStorage.userId,
                placementId,
                locale,
                withCrossPlacmentABTest: true
            ) {
                return content
            } else {
                throw error
            }
        }
    }

    private func fetchPlacementOrFallbackPlacement<Content: AdaptyPlacementContent>(
        _ placementId: String,
        _ locale: AdaptyLocale,
        _ fetchPolicy: AdaptyPlacementFetchPolicy,
        _ loadTimeout: TaskDuration
    ) async throws(AdaptyError) -> Content {
        var userId = profileStorage.userId
        let startTaskTime = Date()

        do {
            return try await withThrowingTimeout(loadTimeout - .milliseconds(500)) {
                let createdUserId = try await self.createdProfileManager.userId
                if createdUserId.isNotEqualProfileId(userId) {
                    log.verbose("fetchPlacementOrFallbackPlacement: profile changed from \(userId) to \(createdUserId)")
                    userId = createdUserId
                }

                return try await self.fetchPlacement(
                    placementId,
                    locale,
                    withPolicy: fetchPolicy,
                    forUserId: userId
                )
            }

        } catch let error as AdaptyError {
            guard error.canUseFallbackServer else { throw error }
        } catch {
            guard error is TimeoutError else { throw .unknown(error) }
        }

        return try await fetchFallbackPlacement(
            placementId,
            locale,
            forUserId: userId,
            withTimeout: loadTimeout.asTimeInterval + startTaskTime.timeIntervalSinceNow
        )
    }

    private func fetchPlacement<Content: AdaptyPlacementContent>(
        _ placementId: String,
        _ locale: AdaptyLocale,
        withPolicy fetchPolicy: AdaptyPlacementFetchPolicy,
        forUserId userId: AdaptyUserId
    ) async throws(AdaptyError) -> Content {
        let manager = try profileManager(withProfileId: userId).orThrows

        let fetchTask: AdaptyResultTask<Content> = Task {
            do throws(AdaptyError) {
                let value: Content = try await fetchPlacement(
                    placementId,
                    locale,
                    forUserId: userId,
                )
                return .success(value)
            } catch {
                return .failure(error)
            }
        }

        let cached: Content? = manager
            .placementStorage
            .getPlacementByLocale(locale,
                                  orDefaultLocale: true,
                                  withPlacementId: placementId,
                                  withVariationId: manager.crossPlacmentStorage.state?.variationId(placementId: placementId))?
            .withFetchPolicy(fetchPolicy)?
            .value

        if let cached {
            return cached
        } else {
            let result = await withTaskCancellationHandler {
                await fetchTask.value
            } onCancel: {
                fetchTask.cancel()
            }
            return try result.get()
        }
    }

    private func fetchPlacement<Content: AdaptyPlacementContent>(
        _ placementId: String,
        _ locale: AdaptyLocale,
        forUserId userId: AdaptyUserId
    ) async throws(AdaptyError) -> Content {
        while true {
            let (segmentId, cached, isTestUser, crossPlacementState, variationId) = try { () throws(AdaptyError) in
                let manager = try profileManager(withProfileId: userId).orThrows
                let crossPlacementState = manager.crossPlacmentStorage.state
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
                    manager.segmentId,
                    cached,
                    manager.isTestUser,
                    crossPlacementState,
                    variationId
                )
            }()

            let requestWithSpecialVariation = variationId != nil

            do {
                var chosen: AdaptyPlacementChosen<Content>

                if let variationId {
                    chosen = try await httpSession.fetchPlacement(
                        apiKeyPrefix: apiKeyPrefix,
                        userId: userId,
                        placementId: placementId,
                        variationId: variationId,
                        locale: locale,
                        cached: cached,
                        disableServerCache: isTestUser
                    )
                } else if let crossPlacementState, crossPlacementState.canParticipateInABTest {
                    chosen = try await httpSession.fetchPlacementVariations(
                        apiKeyPrefix: apiKeyPrefix,
                        userId: userId,
                        placementId: placementId,
                        locale: locale,
                        segmentId: segmentId,
                        cached: cached,
                        crossPlacementEligible: true,
                        variationIdResolver: { @AdaptyActor placementId, draw in
                            var crossPlacementState = crossPlacementState
                            let manager = try? self.profileManager(withProfileId: draw.userId)

                            if let manager {
                                guard let state = manager.crossPlacmentStorage.state else {
                                    // We are prohibited from participating in Cross AB Tests
                                    if draw.participatesInCrossPlacementABTest {
                                        Log.crossAB.verbose("Cross-AB-test placementId = \(placementId), DISABLED -> repeat")
                                        throw ResponseDecodingError.crossPlacementABTestDisabled
                                    } else {
                                        Log.crossAB.verbose("Cross-AB-test placementId = \(placementId), DISABLED -> variationId = \(draw.content.variationId) DRAW")
                                        return draw.content.variationId
                                    }
                                }
                                crossPlacementState = state
                            }

                            if crossPlacementState.canParticipateInABTest {
                                if draw.participatesInCrossPlacementABTest {
                                    Log.crossAB.verbose("Cross-AB-test placementId = \(placementId), BEGIN    -> variationId = \(draw.content.variationId), state = \(draw.variationIdByPlacements) DRAW")
                                    manager?.crossPlacmentStorage.setState(.init(
                                        variationIdByPlacements: draw.variationIdByPlacements,
                                        version: crossPlacementState.version
                                    ))
                                } else {
                                    Log.crossAB.verbose("Cross-AB-test placementId = \(placementId), BEGIN-NO-CROSS -> variationId = \(draw.content.variationId) DRAW")
                                }
                                return draw.content.variationId
                            } else if let variationId = crossPlacementState.variationId(placementId: placementId) {
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
                        userId: userId,
                        placementId: placementId,
                        locale: locale,
                        segmentId: segmentId,
                        cached: cached,
                        crossPlacementEligible: false,
                        variationIdResolver: nil,
                        disableServerCache: isTestUser
                    )
                }

                if let manager = try? profileManager(withProfileId: userId) {
                    chosen = manager.placementStorage.savedPlacementChosen(chosen)
                }

                Adapty.trackEventIfNeed(chosen)
                return chosen.content

            } catch {
                guard !requestWithSpecialVariation else {
                    throw error.asAdaptyError
                }

                if error.responseDecodingError([.notFoundVariationId, .crossPlacementABTestDisabled]) { continue }

                guard Backend.wrongProfileSegmentId(error),
                      try await updateSegmentId(for: userId, oldSegmentId: segmentId)
                else {
                    throw error.asAdaptyError
                }
            }
        }

        func updateSegmentId(for userId: AdaptyUserId, oldSegmentId: String) async throws(AdaptyError) -> Bool {
            let manager = try profileManager(withProfileId: userId).orThrows
            guard manager.segmentId == oldSegmentId else { return true }
            return await manager.fetchSegmentId() != oldSegmentId
        }
    }

    func getCacheOrFallbackFilePlacement<Content: AdaptyPlacementContent>(
        _ userId: AdaptyUserId,
        _ placementId: String,
        _ locale: AdaptyLocale,
        withCrossPlacmentABTest: Bool
    ) -> Content? {
        let chosen: AdaptyPlacementChosen<Content>? =
            if let manager = try? profileManager(withProfileId: userId) {
                manager.placementStorage.getPlacementWithFallback(
                    byPlacementId: placementId,
                    withVariationId: withCrossPlacmentABTest ? manager.crossPlacmentStorage.state?.variationId(placementId: placementId) : nil,
                    userId: userId,
                    locale: locale
                )
            } else {
                Adapty.fallbackPlacements?.getPlacement(
                    byPlacementId: placementId,
                    withVariationId: nil,
                    userId: userId
                )
            }

        guard let chosen else { return nil }

        Adapty.trackEventIfNeed(chosen)
        return chosen.content
    }

    private func fetchFallbackPlacement<Content: AdaptyPlacementContent>(
        _ placementId: String,
        _ locale: AdaptyLocale,
        forUserId userId: AdaptyUserId,
        withTimeout timeoutInterval: TimeInterval?
    ) async throws(AdaptyError) -> Content {
        var params: (cached: Content?, isTestUser: Bool, variationId: String?)?
        while true {
            params = {
                guard let manager = try? profileManager(withProfileId: userId) else { return nil }
                let variationId = manager.crossPlacmentStorage.state?.variationId(placementId: placementId)
                return (
                    cached: manager.placementStorage.getPlacementByLocale(locale, orDefaultLocale: false, withPlacementId: placementId, withVariationId: variationId)?.value,
                    isTestUser: manager.isTestUser,
                    variationId: variationId
                )
            }() ?? params

            if let cached = params?.cached {
                return cached
            }

            do {
                var chosen: AdaptyPlacementChosen<Content>
                if let variationId = params?.variationId {
                    chosen = try await httpFallbackSession.fetchFallbackPlacement(
                        apiKeyPrefix: apiKeyPrefix,
                        userId: userId,
                        placementId: placementId,
                        paywallVariationId: variationId,
                        locale: locale,
                        cached: nil,
                        disableServerCache: params?.isTestUser ?? false,
                        timeoutInterval: timeoutInterval
                    )
                } else {
                    chosen = try await httpFallbackSession.fetchFallbackPlacementVariations(
                        apiKeyPrefix: apiKeyPrefix,
                        userId: userId,
                        placementId: placementId,
                        locale: locale,
                        cached: params?.cached,
                        crossPlacementEligible: false,
                        variationIdResolver: nil,
                        disableServerCache: params?.isTestUser ?? false,
                        timeoutInterval: timeoutInterval
                    )
                }

                if let manager = try? profileManager(withProfileId: userId) {
                    chosen = manager.placementStorage.savedPlacementChosen(chosen)
                }

                Adapty.trackEventIfNeed(chosen)
                return chosen.content

            } catch {
                if error.responseDecodingError([.notFoundVariationId]) {
                    continue
                } else {
                    throw error.asAdaptyError
                }
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

private extension Error {}

private extension AdaptyError {
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

private extension HTTPError {
    func responseDecodingError(_ decodingError: Set<ResponseDecodingError>) -> Bool {
        guard case let .decoding(_, _, _, _, _, value) = self,
              let value = value as? ResponseDecodingError
        else { return false }

        return decodingError.contains(value)
    }
}
