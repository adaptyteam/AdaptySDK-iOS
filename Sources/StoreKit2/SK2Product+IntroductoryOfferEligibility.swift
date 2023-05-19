//
//  SK2Product+IntroductoryOfferEligibility.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 3.05.2023
//

import StoreKit

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
extension Product {
    var introductoryOfferEligibility: AdaptyEligibility {
        get async {
            guard
                let subscription = subscription,
                subscription.introductoryOffer != nil else {
                return .notApplicable
            }

            return AdaptyEligibility(booleanLiteral: await subscription.isEligibleForIntroOffer)
        }
    }
}
