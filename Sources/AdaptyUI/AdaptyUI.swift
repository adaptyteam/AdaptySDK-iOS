//
//  AdaptyUI.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 19.01.2023
//  Copyright © 2023 Adapty. All rights reserved.
//

public enum AdaptyUI {
    public static func getPaywallConfiguration(paywall: AdaptyPaywall,
                                               _ completion: @escaping AdaptyResultCompletion<AdaptyUI.PaywallConfiguration>) {
        Adapty.async(completion) { manager, completion in
            manager.getProfileManager { profileManager in
                guard let profileManager = try? profileManager.get() else {
                    completion(.failure(profileManager.error!))
                    return
                }
                profileManager.getUIPaywallConfiguration(paywall: paywall, completion)
            }
        }
    }
}

extension AdaptyProfileManager {
    fileprivate func getUIPaywallConfiguration(paywall: AdaptyPaywall, _ completion: @escaping AdaptyResultCompletion<AdaptyUI.PaywallConfiguration>) {
        manager.httpSession.performFetchUIPaywallConfigurationRequest(variationId: paywall.variationId,
                                                                      locale: paywall.locale,
                                                                      responseHash: nil) {
            [weak self] (result: AdaptyResult<VH<AdaptyUI.PaywallConfiguration?>>) in

            switch result {
            case let .failure(error):
                completion(.failure(error))
            case let .success(paywall):

                guard let self = self, self.isActive else {
                    completion(.failure(AdaptyError.profileWasChanged()))
                    return
                }

                if let value = paywall.value {
                    completion(.success(value))
                    return
                }

                completion(.failure(AdaptyError.cacheHasNotPaywall()))
            }
        }
    }
}
