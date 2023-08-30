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
            let paywallId: String
            let paywallVariationId: String
            let locale: String
            let builderVersion: String

            enum CodingKeys: String, CodingKey {
                case paywallId = "paywall_id"
                case paywallVariationId = "paywall_variation_id"
                case locale
                case builderVersion = "builder_version"
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
            manager.getProfileManager { profileManager in
                guard let profileManager = try? profileManager.get() else {
                    completion(.failure(profileManager.error!))
                    return
                }
                profileManager.getViewConfiguration(
                    paywallId: parameters.paywallId,
                    paywallVariationId: parameters.paywallVariationId,
                    locale: parameters.locale,
                    builderVersion: parameters.builderVersion,
                    responseHash: nil,
                    completion)
            }
        }
    }
}

extension AdaptyProfileManager {
    fileprivate func getViewConfiguration(paywallId: String,
                                          paywallVariationId: String,
                                          locale: String,
                                          builderVersion: String,
                                          responseHash: String?,
                                          _ completion: @escaping AdaptyResultCompletion<AdaptyUI.ViewConfiguration>) {
        manager.httpSession.performFetchViewConfigurationRequest(paywallId: paywallId,
                                                                 paywallVariationId: paywallVariationId,
                                                                 locale: locale,
                                                                 builderVersion: builderVersion,
                                                                 responseHash: responseHash) {
            [weak self] (result: AdaptyResult<VH<AdaptyUI.ViewConfiguration?>>) in

            switch result {
            case let .failure(error):
                completion(.failure(error))
            case let .success(viewConfiguration):
                guard let self = self, self.isActive else {
                    completion(.failure(.profileWasChanged()))
                    return
                }

                if let value = viewConfiguration.value {
                    completion(.success(value))
                    return
                }

                completion(.failure(.cacheHasNoViewConfiguration()))
            }
        }
    }
}
