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
        fetchPolicy: AdaptyPaywall.FetchPolicy = .default,
        loadTimeout: TimeInterval? = nil
    ) async throws -> AdaptyPaywall {
        let loadTimeout = (loadTimeout ?? .defaultLoadPaywallTimeout).allowedLoadPaywallTimeout
        let locale = locale.map { AdaptyLocale(id: $0) } ?? .defaultPaywallLocale

        let logParams: EventParameters = [
            "placement_id": placementId,
            "locale": locale,
            "fetch_policy": fetchPolicy,
            "load_timeout": loadTimeout.asMilliseconds,
        ]

        return try await withActivatedSDK(methodName: .getPaywall, logParams: logParams) { sdk in
            let paywall = try await sdk.getPaywall(
                placementId,
                locale,
                fetchPolicy,
                loadTimeout
            )
            Adapty.sendImageUrlsToObserver(paywall)

            return paywall
        }
    }

    private func getPaywall(
        _ placementId: String,
        _ locale: AdaptyLocale,
        _ fetchPolicy: AdaptyPaywall.FetchPolicy,
        _ loadTimeout: TaskDuration
    ) async throws -> AdaptyPaywall {
        let profileId = profileStorage.profileId

        do {
            return try await withThrowingTimeout(loadTimeout - .milliseconds(500)) {
                try await self.fetchPaywall(
                    profileId,
                    placementId,
                    locale,
                    fetchPolicy
                )
            }
        } catch let error where error.canUseFallbackServer {
            return try await fetchFallbackPaywall(
                profileId,
                placementId,
                locale,
                httpFallbackSession
            )
        } catch {
            let manager = try profileManager(with: profileId).orThrows
            guard let chosen = manager
                .paywallsStorage
                .getPaywallWithFallback(
                    byPlacementId: placementId,
                    withVariationId: manager.storage.crossPlacementState?.variationId(placementId: placementId),
                    profileId: profileId,
                    locale: locale
                )
            else {
                throw error.asAdaptyError ?? AdaptyError.fetchPaywallFailed(unknownError: error)
            }
            Adapty.trackEventIfNeed(chosen)
            return chosen.value
        }
    }

    private func fetchPaywall(
        _ profileId: String,
        _ placementId: String,
        _ locale: AdaptyLocale,
        _ fetchPolicy: AdaptyPaywall.FetchPolicy
    ) async throws -> AdaptyPaywall {
        let manager = try await createdProfileManager

        guard manager.profileId == profileId else {
            throw AdaptyError.profileWasChanged()
        }

        let fetchTask = Task {
            try await fetchPaywall(
                profileId,
                placementId,
                locale
            )
        }

        let cached = manager
            .paywallsStorage
            .getPaywallByLocale(locale,
                                orDefaultLocale: true,
                                withPlacementId: placementId,
                                withVariationId: manager.storage.crossPlacementState?.variationId(placementId: placementId))?
            .withFetchPolicy(fetchPolicy)?
            .value

        let paywall =
            if let cached {
                cached
            } else {
                try await withTaskCancellationHandler {
                    try await fetchTask.value
                } onCancel: {
                    fetchTask.cancel()
                }
            }

        return paywall
    }

    private func fetchPaywall(
        _ profileId: String,
        _ placementId: String,
        _ locale: AdaptyLocale
    ) async throws -> AdaptyPaywall {
        while true {
            let (segmentId, cached, isTestUser, crossPlacementState, paywallVariationId) = try {
                let manager = try profileManager(with: profileId).orThrows
                let crossPlacementState = manager.storage.crossPlacementState
                let variationId = crossPlacementState?.variationId(placementId: placementId)
                return (
                    manager.profile.value.segmentId,
                    manager.paywallsStorage.getPaywallByLocale(locale, orDefaultLocale: false, withPlacementId: placementId, withVariationId: variationId)?.value,
                    manager.profile.value.isTestUser,
                    crossPlacementState,
                    variationId
                )
            }()

            let caseWithPaywallVariation = paywallVariationId != nil

            do {
                var chosen: AdaptyPaywallChosen

                if let paywallVariationId {
                    chosen = try await httpSession.fetchPaywall(
                        apiKeyPrefix: apiKeyPrefix,
                        profileId: profileId,
                        placementId: placementId,
                        paywallVariationId: paywallVariationId,
                        locale: locale,
                        cached: cached,
                        disableServerCache: isTestUser
                    )
                } else if let crossPlacementState, crossPlacementState.canParticipateInABTest {
                    chosen = try await httpSession.fetchPaywallVariations(
                        apiKeyPrefix: apiKeyPrefix,
                        profileId: profileId,
                        placementId: placementId,
                        locale: locale,
                        segmentId: segmentId,
                        cached: cached,
                        crossPlacementEligible: true,
                        variationIdResolver: { @AdaptyActor placementId, selectedPaywall in
                            guard let manager = self.tryProfileManagerOrNil(with: selectedPaywall.profileId) else {
                                Log.crossAB.debug("Cross-AB-test placementId = \(placementId), error = PROFILE_WAS_CHANGED")
                                throw ResponseDecodingError.profileWasChanged
                            }

                            guard let crossPlacementState = manager.storage.crossPlacementState else {
                                // We are prohibited from participating in Cross AB Tests
                                if selectedPaywall.participatesInCrossPlacementABTest {
                                    Log.crossAB.debug("Cross-AB-test placementId = \(placementId), DISABLED -> repeat")
                                    throw ResponseDecodingError.crossPlacementABTestDisabled
                                } else {
                                    Log.crossAB.debug("Cross-AB-test placementId = \(placementId), DISABLED -> variationId = \(selectedPaywall.variationId) DRAW")
                                    return selectedPaywall.variationId
                                }
                            }

                            if crossPlacementState.canParticipateInABTest {
                                if selectedPaywall.participatesInCrossPlacementABTest {
                                    Log.crossAB.debug("Cross-AB-test placementId = \(placementId), BEGIN    -> variationId = \(selectedPaywall.variationId), state = \(selectedPaywall.variationIdByPlacements) DRAW")
                                    manager.storage.setCrossPlacementState(.init(
                                        variationIdByPlacements: selectedPaywall.variationIdByPlacements,
                                        version: crossPlacementState.version
                                    ))
                                } else {
                                    Log.crossAB.debug("Cross-AB-test placementId = \(placementId), BEGIN-NO-CROSS -> variationId = \(selectedPaywall.variationId) DRAW")
                                }
                                return selectedPaywall.variationId
                            } else if let variationId = manager.storage.crossPlacementState?.variationId(placementId: placementId) {
                                // We are participating in cross AB test: A
                                // And the paywall is from cross AB test: A
                                Log.crossAB.debug("Cross-AB-test placementId = \(placementId), CONTINUE -> variationId = \(variationId)")
                                return variationId
                            } else if !selectedPaywall.participatesInCrossPlacementABTest {
                                // We are participating in cross AB test: A
                                // But the paywall is not in any cross AB test
                                Log.crossAB.debug("Cross-AB-test placementId = \(placementId), CONTINUE-NO-CROSS -> variationId = \(selectedPaywall.variationId) DRAW")
                                return selectedPaywall.variationId
                            } else {
                                // We are participating in cross AB test: A
                                // But the paywall is from cross AB test: B
                                //
                                Log.crossAB.debug("Cross-AB-test placementId = \(placementId), CONTINUE-OTHER-CROSS -> variationId = \(selectedPaywall.variationId) DRAW")
                                return selectedPaywall.variationId
                            }

                        },
                        disableServerCache: isTestUser
                    )
                } else {
                    chosen = try await httpSession.fetchPaywallVariations(
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
                    chosen = manager.paywallsStorage.savedPaywallChosen(chosen)
                }

                Adapty.trackEventIfNeed(chosen)
                return chosen.value

            } catch {
                if error.responseDecodingError([.profileWasChanged]) {
                    throw AdaptyError.profileWasChanged()
                }

                guard !caseWithPaywallVariation else {
                    throw error.asAdaptyError ?? AdaptyError.fetchPaywallFailed(unknownError: error)
                }

                if error.responseDecodingError([.notFoundVariationId, .crossPlacementABTestDisabled]) { continue }

                guard error.wrongProfileSegmentId,
                      try await updateSegmentId(for: profileId, oldSegmentId: segmentId)
                else {
                    throw error.asAdaptyError ?? AdaptyError.fetchPaywallFailed(unknownError: error)
                }
            }
        }

        func updateSegmentId(for profileId: String, oldSegmentId: String) async throws -> Bool {
            let manager = try profileManager(with: profileId).orThrows
            guard manager.profile.value.segmentId == oldSegmentId else { return true }
            return await manager.getProfile().segmentId != oldSegmentId
        }
    }

    func fetchFallbackPaywall(
        _ profileId: String,
        _ placementId: String,
        _ locale: AdaptyLocale,
        _ session: some FetchFallbackPaywallVariationsExecutor
    ) async throws -> AdaptyPaywall {
        while true {
            let (cached, isTestUser, paywallVariationId): (AdaptyPaywall?, Bool, String?) = {
                guard let manager = tryProfileManagerOrNil(with: profileId) else { return (nil, false, nil) }
                let variationId = manager.storage.crossPlacementState?.variationId(placementId: placementId)
                return (
                    manager.paywallsStorage.getPaywallByLocale(locale, orDefaultLocale: false, withPlacementId: placementId, withVariationId: variationId)?.value,
                    manager.profile.value.isTestUser,
                    variationId
                )
            }()

            do {
                var chosen = if let paywallVariationId {
                    try await session.fetchFallbackPaywall(
                        apiKeyPrefix: apiKeyPrefix,
                        profileId: profileId,
                        placementId: placementId,
                        paywallVariationId: paywallVariationId,
                        locale: locale,
                        cached: cached,
                        disableServerCache: isTestUser
                    )
                } else {
                    try await session.fetchFallbackPaywallVariations(
                        apiKeyPrefix: apiKeyPrefix,
                        profileId: profileId,
                        placementId: placementId,
                        locale: locale,
                        cached: cached,
                        crossPlacementEligible: false,
                        variationIdResolver: nil,
                        disableServerCache: isTestUser
                    )
                }

                if let manager = tryProfileManagerOrNil(with: profileId) {
                    chosen = manager.paywallsStorage.savedPaywallChosen(chosen)
                }

                Adapty.trackEventIfNeed(chosen)
                return chosen.value

            } catch {
                if error.responseDecodingError([.notFoundVariationId]) { continue }

                let chosen =
                    if let manager = tryProfileManagerOrNil(with: profileId) {
                        manager.paywallsStorage.getPaywallWithFallback(byPlacementId: placementId, withVariationId: paywallVariationId, profileId: profileId, locale: locale)
                    } else {
                        Adapty.fallbackPaywalls?.getPaywall(byPlacementId: placementId, withVariationId: paywallVariationId, profileId: profileId)
                    }

                guard let chosen else {
                    throw error.asAdaptyError ?? AdaptyError.fetchPaywallFailed(unknownError: error)
                }

                Adapty.trackEventIfNeed(chosen)
                return chosen.value
            }
        }
    }
}

extension TimeInterval {
    static let defaultLoadPaywallTimeout: TimeInterval = 5.0
    static let minimumLoadPaywallTimeout: TimeInterval = 1.0

    var allowedLoadPaywallTimeout: TaskDuration {
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

    func responseDecodingError(_ decodingError: Set<ResponseDecodingError>) -> Bool {
        let error = unwrapped
        if let httpError = error as? HTTPError { return Backend.responseDecodingError(decodingError, httpError) }
        return false
    }
}
