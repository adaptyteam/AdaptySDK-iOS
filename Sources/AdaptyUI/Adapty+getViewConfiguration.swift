//
//  Adapty+getViewConfiguration.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 19.01.2023
//

import Foundation

extension Adapty {
    package static func getViewConfiguration(
        paywall: AdaptyPaywall,
        loadTimeout: TimeInterval = .defaultLoadPaywallTimeout,
        _ completion: @escaping AdaptyResultCompletion<AdaptyUI.LocalizedViewConfiguration>
    ) {
        Adapty.async(completion) { manager, completion in
            manager.getViewConfiguration1(
                paywall: paywall,
                loadTimeout: loadTimeout.allowedLoadPaywallTimeout.dispatchTimeInterval,
                completion
            )
        }
    }

    private func getFallbackViewConfiguration(
        paywallInstanceIdentity: String,
        locale: AdaptyLocale,
        _ completion: @escaping AdaptyResultCompletion<AdaptyUI.ViewConfiguration>
    ) {
        httpFallbackSession.performFetchFallbackViewConfigurationRequest(
            apiKeyPrefix: apiKeyPrefix,
            paywallInstanceIdentity: paywallInstanceIdentity,
            locale: locale,
            disableServerCache: profileStorage.getProfile()?.value.isTestUser ?? false,
            completion
        )
    }

    private func getViewConfiguration1(
        paywall: AdaptyPaywall,
        loadTimeout: DispatchTimeInterval,
        _ completion: @escaping AdaptyResultCompletion<AdaptyUI.LocalizedViewConfiguration>
    ) {
        guard let viewConfiguration = paywall.viewConfiguration else {
            completion(.failure(.isNoViewConfigurationInPaywall()))
            return
        }

        let completion: AdaptyResultCompletion<AdaptyUI.ViewConfiguration> = { result in

            completion(
                result.flatMap {
                    $0.sendImageUrlsToObserver()
                    do {
                        return try .success($0.extractLocale())
                    } catch {
                        return .failure(.decodingViewConfiguration(error))
                    }
                }
            )
        }

        switch viewConfiguration {
        case let .data(data):
            completion(.success(data))
        case let .withoutData(locale, _):
            if let data = restoreViewConfiguration(locale, paywall) {
                completion(.success(data))
            } else {
                fetchViewConfiguration(
                    paywallVariationId: paywall.variationId,
                    paywallInstanceIdentity: paywall.instanceIdentity,
                    locale: locale,
                    loadTimeout: loadTimeout,
                    completion
                )
            }
        }
    }

    private func restoreViewConfiguration(_ locale: AdaptyLocale, _ paywall: AdaptyPaywall) -> AdaptyUI.ViewConfiguration? {
        guard
            let manager = state.initialized, manager.isActive,
            let cached = manager.paywallsCache.getPaywallByLocale(locale, orDefaultLocale: false, withPlacementId: paywall.placementId)?.value,
            paywall.variationId == cached.variationId,
            paywall.instanceIdentity == cached.instanceIdentity,
            paywall.revision == cached.revision,
            paywall.version == cached.version,
            let cachedViewConfiguration = cached.viewConfiguration,
            case let .data(data) = cachedViewConfiguration
        else { return nil }

        return data
    }

    private func fetchViewConfiguration(
        paywallVariationId: String,
        paywallInstanceIdentity: String,
        locale: AdaptyLocale,
        loadTimeout: DispatchTimeInterval,
        _ completion: @escaping AdaptyResultCompletion<AdaptyUI.ViewConfiguration>
    ) {
        var isTerminationCalled = false

        let termination: AdaptyResultCompletion<AdaptyUI.ViewConfiguration> = { [weak self] result in
            guard !isTerminationCalled else { return }
            isTerminationCalled = true

            guard let queue = self?.httpSession.responseQueue,
                  let error = result.error, error.canUseFallbackServer else {
                completion(result)
                return
            }

            queue.async {
                guard let self else {
                    completion(result)
                    return
                }

                self.getFallbackViewConfiguration(
                    paywallInstanceIdentity: paywallInstanceIdentity,
                    locale: locale,
                    completion
                )
            }
        }

        httpSession.performFetchViewConfigurationRequest(
            apiKeyPrefix: apiKeyPrefix,
            paywallVariationId: paywallVariationId,
            locale: locale,
            disableServerCache: self.profileStorage.getProfile()?.value.isTestUser ?? false,
            termination
        )

        if loadTimeout != .never, !isTerminationCalled {
            Adapty.underlayQueue.asyncAfter(deadline: .now() - .milliseconds(500) + loadTimeout) {
                termination(.failure(.fetchViewConfigurationTimeout()))
            }
        }
    }
}
