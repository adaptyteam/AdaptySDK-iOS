//
//  SK1Product.SubscriptionPeriod .Unit.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 23.09.2024
//

import StoreKit

extension SK1Product.SubscriptionPeriod {
    typealias Unit = SKProduct.PeriodUnit
}

extension SK1Product.SubscriptionPeriod.Unit {
    var asAdaptyPeriodUnit: AdaptyPeriodUnit {
        switch self {
        case .day: .day
        case .week: .week
        case .month: .month
        case .year: .year
        @unknown default: .unknown
        }
    }
}
