//
//  AdaptyUI.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 19.01.2023
//

import Foundation

/// AdaptyUI is a module intended to display paywalls created with the Paywall Builder.
/// To make full use of this functionality, you need to install an [additional library](https://github.com/adaptyteam/AdaptyUI-iOS), as well as make additional setups in the Adapty Dashboard.
/// You can find more information in the corresponding section of [our documentation](https://docs.adapty.io/docs/paywall-builder-getting-started).
public enum AdaptyUI {
    /// This method is intended to be used directly. Read [AdaptyUI Documentation](https://docs.adapty.io/docs/paywall-builder-installation-ios) first.
    public static func getViewConfiguration(
        from decoder: JSONDecoder,
        data: Data,
        _ completion: @escaping AdaptyResultCompletion<AdaptyUI.ViewConfiguration>
    ) {
        struct PrivateParameters: Decodable {
            let paywallVariationId: String
            let paywallInstanceIdentity: String
            let locale: AdaptyLocale
            let adaptyUISDKVersion: String
            let loadTimeout: TimeInterval?

            enum CodingKeys: String, CodingKey {
                case paywallVariationId = "paywall_variation_id"
                case paywallInstanceIdentity = "paywall_instance_id"
                case locale
                case adaptyUISDKVersion = "ui_sdk_version"
                case loadTimeout = "load_timeout"
            }
        }

        let parameters: PrivateParameters
        do {
            parameters = try decoder.decode(PrivateParameters.self, from: data)
        } catch {
            completion(.failure(.decodingGetViewConfiguration(error)))
            return
        }

        Adapty.async(completion) { manager, completion in
            manager.getViewConfiguration(
                paywallVariationId: parameters.paywallVariationId,
                paywallInstanceIdentity: parameters.paywallInstanceIdentity,
                locale: parameters.locale,
                adaptyUISDKVersion: parameters.adaptyUISDKVersion,
                loadTimeout: (parameters.loadTimeout?.allowedLoadPaywallTimeout ?? .defaultLoadPaywallTimeout).dispatchTimeInterval
            ) { result in
                result.sendImageUrlsToObserver(forLocale: parameters.locale)
                completion(result)
            }
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
