//
//  ProductSubscriptionPeriod.swift
//  Adapty
//
//  Created by Aleksei Valiano on 20.10.2022.
//

import Foundation
import StoreKit

public struct ProductSubscriptionPeriod {
    /// A unit of time that a subscription period is specified in.
    public let unit: PeriodUnit
    
    /// A number of period units.
    public let numberOfUnits: Int
}

extension ProductSubscriptionPeriod {
    @available(iOS 11.2, macOS 10.13.2, *)
    init(subscriptionPeriod: SKProductSubscriptionPeriod) {
        self.init(unit: PeriodUnit(unit: subscriptionPeriod.unit), numberOfUnits: subscriptionPeriod.numberOfUnits)
    }
}

extension ProductSubscriptionPeriod: CustomStringConvertible {
    public var description: String {
        "\(numberOfUnits) \(unit)"
    }
}

extension ProductSubscriptionPeriod: Equatable, Sendable {}

extension ProductSubscriptionPeriod: Codable {
    enum CodingKeys: String, CodingKey {
        case unit
        case numberOfUnits
    }
}
