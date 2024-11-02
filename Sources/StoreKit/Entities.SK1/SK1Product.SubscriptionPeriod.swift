//
//  SK1Product.SubscriptionPeriod.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 23.09.2024
//

import StoreKit

extension SK1Product {
    typealias SubscriptionPeriod = SKProductSubscriptionPeriod
}

extension SK1Product.SubscriptionPeriod {
    var asAdaptyProductSubscriptionPeriod: AdaptyProductSubscriptionPeriod {
         .init(unit: unit.asAdaptyPeriodUnit, numberOfUnits: numberOfUnits)
    }
}