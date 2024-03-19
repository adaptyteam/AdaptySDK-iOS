//
//  AdaptyProductSubscriptionPeriod.swift
//  AdaptySDK
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
    init(subscriptionPeriod: SKProductSubscriptionPeriod) {
        self.init(unit: AdaptyPeriodUnit(unit: subscriptionPeriod.unit), numberOfUnits: subscriptionPeriod.numberOfUnits)
    }

    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
    init(subscriptionPeriod: SK2Product.SubscriptionPeriod) {
        self.init(unit: AdaptyPeriodUnit(unit: subscriptionPeriod.unit), numberOfUnits: subscriptionPeriod.value)
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
