//
//  SK1Product+IntroductoryOfferEligibility.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 3.05.2023
//

import StoreKit

extension SKProduct {
    var introductoryOfferEligibility: AdaptyEligibility? {
        guard let period = subscriptionPeriod,
              period.numberOfUnits > 0,
              introductoryPrice != nil else {
            return .notApplicable
        }

        return nil
    }
}
