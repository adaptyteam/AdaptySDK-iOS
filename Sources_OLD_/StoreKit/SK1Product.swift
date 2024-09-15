//
//  SK1Product.swift
//
//
//  Created by Aleksei Valiano on 01.02.2024
//
//

import StoreKit

typealias SK1Product = SKProduct

extension SK1Product {
    var introductoryOfferEligibility: AdaptyEligibility? {
        guard let period = subscriptionPeriod,
              period.numberOfUnits > 0,
              introductoryPrice != nil else {
            return .notApplicable
        }

        return nil
    }
}
