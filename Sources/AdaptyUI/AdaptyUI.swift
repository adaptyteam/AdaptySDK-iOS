//
//  AdaptyUI.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 19.01.2023
//  Copyright © 2023 Adapty. All rights reserved.
//

import Foundation

/// AdaptyUI is a module intended to display paywalls created with the Paywall Builder.
/// To make full use of this functionality, you need to install an [additional library](https://github.com/adaptyteam/AdaptyUI-iOS), as well as make additional setups in the Adapty Dashboard.
/// You can find more information in the corresponding section of [our documentation](https://docs.adapty.io/docs/paywall-builder-getting-started).
public enum AdaptyUI {
    /// This method is intended to be used directly. Read [AdaptyUI Documentation](https://docs.adapty.io/docs/paywall-builder-installation-ios) first.
    public static func getViewConfiguration(
        _ parameters: [String: Any],
        _ completion: @escaping AdaptyResultCompletion<AdaptyUI.LocalizedViewConfiguration>
    ) {
        enum ParametersError: Error {
            case paywallNotFound
            case adaptyUISDKVersionNotFound
        }

        guard let paywall = parameters["paywall"] as? AdaptyPaywall else {
            completion(.failure(.decodingGetViewConfiguration(ParametersError.paywallNotFound)))
            return
        }

        guard let adaptyUISDKVersion = parameters["ui_sdk_version"] as? String else {
            completion(.failure(.decodingGetViewConfiguration(ParametersError.adaptyUISDKVersionNotFound)))
            return
        }

        let loadTimeout = parameters["load_timeout"] as? TimeInterval

        Adapty.async(completion) { manager, completion in
            manager.getViewConfiguration(
                paywall: paywall,
                adaptyUISDKVersion: adaptyUISDKVersion,
                loadTimeout: (loadTimeout?.allowedLoadPaywallTimeout ?? .defaultLoadPaywallTimeout).dispatchTimeInterval,
                completion
            )
        }
    }
}

extension Adapty {
    private func getFallbackViewConfiguration(
        paywallInstanceIdentity: String,
        locale: AdaptyLocale,
        _ completion: @escaping AdaptyResultCompletion<AdaptyUI.ViewConfiguration>
    ) {
        httpFallbackSession.performFetchFallbackViewConfigurationRequest(
            apiKeyPrefix: apiKeyPrefix,
            paywallInstanceIdentity: paywallInstanceIdentity,
            locale: locale,
            completion
        )
    }

    fileprivate func getViewConfiguration(
        paywall: AdaptyPaywall,
        adaptyUISDKVersion: String,
        loadTimeout: DispatchTimeInterval,
        _ completion: @escaping AdaptyResultCompletion<AdaptyUI.LocalizedViewConfiguration>
    ) {
        guard let viewConfiguration = paywall.viewConfiguration else {
            completion(.failure(.isNoViewConfigurationInPaywall()))
            return
        }

        let completion: AdaptyResultCompletion<AdaptyUI.ViewConfiguration> = { result in

            completion(result.map {
                $0.sendImageUrlsToObserver()
                return $0.extractLocale($0.responseLocale)
            })
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
                    adaptyUISDKVersion: adaptyUISDKVersion,
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
        adaptyUISDKVersion: String,
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
            adaptyUISDKVersion: adaptyUISDKVersion,
            termination
        )

        if loadTimeout != .never, !isTerminationCalled {
            Adapty.underlayQueue.asyncAfter(deadline: .now() - .milliseconds(500) + loadTimeout) {
                termination(.failure(.fetchViewConfigurationTimeout()))
            }
        }
    }
}
