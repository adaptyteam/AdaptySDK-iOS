//
//  AdaptyUI.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 19.01.2023
//  Copyright © 2023 Adapty. All rights reserved.
//

/// AdaptyUI is a module intended to display paywalls created with the Paywall Builder.
/// To make full use of this functionality, you need to install an [additional library](https://github.com/adaptyteam/AdaptySDK-iOS-VisualPaywalls.git), as well as make additional setups in the Adapty Dashboard.
/// You can find more information in the corresponding section of [our documentation](https://docs.adapty.io/docs/paywall-builder-getting-started).
public enum AdaptyUI {
    /// If you are using the [Paywall Builder](https://docs.adapty.io/docs/paywall-builder-getting-started), you can use this method to get a configuration object for your paywall.
    ///
    /// - Parameters:
    ///   - forPaywall: the ``AdaptyPaywall`` for which you want to get a configuration.
    ///   - completion: A result containing the ``AdaptyUI.ViewConfiguration>`` object. Use it with [AdaptyUI](https://github.com/adaptyteam/AdaptySDK-iOS-VisualPaywalls.git) library.
    public static func getViewConfiguration(forPaywall paywall: AdaptyPaywall,
                                            _ completion: @escaping AdaptyResultCompletion<AdaptyUI.ViewConfiguration>) {
        Adapty.async(completion) { manager, completion in
            manager.getProfileManager { profileManager in
                guard let profileManager = try? profileManager.get() else {
                    completion(.failure(profileManager.error!))
                    return
                }
                profileManager.getUIViewConfiguration(forPaywall: paywall, completion)
            }
        }
    }
}

extension AdaptyProfileManager {
    fileprivate func getUIViewConfiguration(forPaywall paywall: AdaptyPaywall, _ completion: @escaping AdaptyResultCompletion<AdaptyUI.ViewConfiguration>) {
        manager.httpSession.performFetchUIViewConfigurationRequest(paywallId: paywall.id,
                                                                   paywallVariationId: paywall.variationId,
                                                                   locale: paywall.locale,
                                                                   responseHash: nil) {
            [weak self] (result: AdaptyResult<VH<AdaptyUI.ViewConfiguration?>>) in

            switch result {
            case let .failure(error):
                completion(.failure(error))
            case let .success(paywall):

                guard let self = self, self.isActive else {
                    completion(.failure(.profileWasChanged()))
                    return
                }

                if let value = paywall.value {
                    completion(.success(value))
                    return
                }

                completion(.failure(.cacheHasNotPaywall()))
            }
        }
    }
}
