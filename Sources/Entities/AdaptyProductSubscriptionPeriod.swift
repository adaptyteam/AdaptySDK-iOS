//
//  AdaptyProductSubscriptionPeriod.swift
//  Adapty
//
//  Created by Aleksei Valiano on 20.10.2022.
//

import Foundation
import StoreKit

public struct AdaptyProductSubscriptionPeriod {
    /// A unit of time that a subscription period is specified in.
    public let unit: AdaptyPeriodUnit

    /// A number of period units.
    public let numberOfUnits: Int
}

extension AdaptyProductSubscriptionPeriod {
    @available(iOS 11.2, macOS 10.13.2, *)
    init(subscriptionPeriod: SKProductSubscriptionPeriod) {
        self.init(unit: AdaptyPeriodUnit(unit: subscriptionPeriod.unit), numberOfUnits: subscriptionPeriod.numberOfUnits)
    }
}

extension AdaptyProductSubscriptionPeriod: CustomStringConvertible {
    public var description: String {
        "\(numberOfUnits) \(unit)"
    }
}

extension AdaptyProductSubscriptionPeriod: Equatable, Sendable {}

extension AdaptyProductSubscriptionPeriod: Codable {
    enum CodingKeys: String, CodingKey {
        case unit
        case numberOfUnits = "number_of_units"
    }
}
