//
//  SK1Product+IntroductoryOfferEligibility.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 3.05.2023
//

import StoreKit

extension SKProduct {
    var introductoryOfferEligibility: AdaptyEligibility? {
        guard #available(iOS 11.2, macOS 10.13.2, tvOS 11.2, watchOS 6.2, *),
              let period = subscriptionPeriod,
              period.numberOfUnits > 0,
              introductoryPrice != nil else {
            return .notApplicable
        }

        return nil
    }
}
