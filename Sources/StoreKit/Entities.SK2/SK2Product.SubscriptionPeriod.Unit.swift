//
//  SK2Product.SubscriptionPeriod.Unit.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 23.09.2024
//

import StoreKit

extension SK2Product.SubscriptionPeriod.Unit {
    var asAdaptySubscriptionPeriodUnit: AdaptySubscriptionPeriod.Unit {
        switch self {
        case .day: .day
        case .week: .week
        case .month: .month
        case .year: .year
        @unknown default: .unknown
        }
    }
}
