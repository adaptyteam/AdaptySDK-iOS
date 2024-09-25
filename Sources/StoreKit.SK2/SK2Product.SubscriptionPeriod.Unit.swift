//
//  SK2Product.SubscriptionPeriod.Unit.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 23.09.2024
//

import StoreKit

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
extension SK2Product.SubscriptionPeriod.Unit {
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
