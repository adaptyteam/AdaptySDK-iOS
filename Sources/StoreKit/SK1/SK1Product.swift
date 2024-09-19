//
//  SK1Product.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 01.02.2024
//
//

import StoreKit

typealias SK1Product = SKProduct

extension SK1Product {
    typealias SubscriptionOffer = SKProductDiscount
    typealias SubscriptionPeriod = SKProductSubscriptionPeriod
    
    var introductoryOfferEligibility: AdaptyEligibility? {
        guard let period = subscriptionPeriod,
              period.numberOfUnits > 0,
              introductoryPrice != nil else {
            return .notApplicable
        }

        return nil
    }
}

extension SK1Product.SubscriptionPeriod {
    typealias Unit = SKProduct.PeriodUnit
}

extension SK1Product.SubscriptionOffer {
    typealias OfferType = `Type`
}
