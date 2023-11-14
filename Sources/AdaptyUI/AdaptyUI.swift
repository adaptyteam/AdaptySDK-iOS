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
    public static func getViewConfiguration(data: Data,
                                            _ completion: @escaping AdaptyResultCompletion<AdaptyUI.ViewConfiguration>) {
        struct PrivateParameters: Decodable {
            let paywallVariationId: String
            let locale: AdaptyLocale
            let builderVersion: String
            let adaptyUISDKVersion: String
            let loadTimeInterval: TimeInterval

            enum CodingKeys: String, CodingKey {
                case paywallVariationId = "paywall_variation_id"
                case locale
                case builderVersion = "builder_version"
                case adaptyUISDKVersion = "ui_sdk_version"
                case loadTimeInterval = "load_timeinterval"
            }
        }

        let parameters: PrivateParameters
        do {
            parameters = try Backend.decoder.decode(PrivateParameters.self, from: data)
        } catch {
            completion(.failure(.decodingGetViewConfiguration(error)))
            return
        }

        Adapty.async(completion) { manager, completion in
            manager.getViewConfiguration(paywallVariationId: parameters.paywallVariationId,
                                         locale: parameters.locale,
                                         builderVersion: parameters.builderVersion,
                                         adaptyUISDKVersion: parameters.adaptyUISDKVersion,
                                         loadTimeInterval: parameters.loadTimeInterval,
                                         responseHash: nil,
                                         completion)
        }
    }
}

extension Adapty {
    fileprivate func getViewConfiguration(paywallVariationId: String,
                                          locale: AdaptyLocale,
                                          builderVersion: String,
                                          adaptyUISDKVersion: String,
                                          loadTimeInterval: TimeInterval = 5.000,
                                          responseHash: String?,
                                          _ completion: @escaping AdaptyResultCompletion<AdaptyUI.ViewConfiguration>) {
        httpSession.performFetchViewConfigurationRequest(apiKeyPrefix: apiKeyPrefix,
                                                         paywallVariationId: paywallVariationId,
                                                         locale: locale,
                                                         builderVersion: builderVersion,
                                                         adaptyUISDKVersion: adaptyUISDKVersion,
                                                         responseHash: responseHash) { [weak self] (result: AdaptyResult<VH<AdaptyUI.ViewConfiguration?>>) in

            switch result {
            case let .failure(error):

                guard let queue = self?.httpSession.responseQueue,
                      let httpError = error.wrapped as? HTTPError,
                      Backend.canUseFallbackServer(error: httpError) else {
                    completion(.failure(error))
                    break
                }

                queue.async {
                    guard let manager = self else {
                        completion(.failure(error))
                        return
                    }

                    manager
                        .httpFallbackSession
                        .performFetchFallbackViewConfigurationRequest(apiKeyPrefix: manager.apiKeyPrefix,
                                                                      paywallVariationId: paywallVariationId,
                                                                      locale: locale,
                                                                      builderVersion: builderVersion,
                                                                      completion)
                }

            case let .success(viewConfiguration):
                guard let value = viewConfiguration.value else {
                    completion(.failure(.cacheHasNoViewConfiguration()))
                    return
                }
                completion(.success(value))
            }
        }
    }
}
