//
//  SK2Product.SubscriptionPeriod.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 23.09.2024
//

import StoreKit

extension SK2Product.SubscriptionPeriod {
    var asAdaptySubscriptionPeriod: AdaptySubscriptionPeriod {
        .init(unit: unit.asAdaptySubscriptionPeriodUnit, numberOfUnits: value)
    }
}
