//
//  SK2Product.swift
//
//
//  Created by Aleksei Valiano on 01.02.2024
//
//

import StoreKit

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
typealias SK2Product = Product

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
extension SK2Product {
    var introductoryOfferEligibility1: AdaptyEligibility {
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
