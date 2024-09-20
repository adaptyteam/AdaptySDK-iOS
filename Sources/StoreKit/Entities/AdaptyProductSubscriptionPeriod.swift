//
//  AdaptyProductSubscriptionPeriod.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 20.10.2022.
//

import StoreKit

public struct AdaptyProductSubscriptionPeriod: Sendable, Hashable {
    /// A unit of time that a subscription period is specified in.
    public let unit: AdaptyPeriodUnit

    /// A number of period units.
    public let numberOfUnits: Int

    init(unit: AdaptyPeriodUnit, numberOfUnits: Int) {
        switch unit {
        case .day where numberOfUnits.isMultiple(of: 7):
            self.numberOfUnits = numberOfUnits / 7
            self.unit = .week
        case .month where numberOfUnits.isMultiple(of: 12):
            self.numberOfUnits = numberOfUnits / 12
            self.unit = .year
        default:
            self.numberOfUnits = numberOfUnits
            self.unit = unit
        }
    }
}

extension AdaptyProductSubscriptionPeriod {
    init(subscriptionPeriod: SK1Product.SubscriptionPeriod) {
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

extension AdaptyProductSubscriptionPeriod: Codable {
    enum CodingKeys: String, CodingKey {
        case unit
        case numberOfUnits = "number_of_units"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            unit: container.decode(AdaptyPeriodUnit.self, forKey: .unit),
            numberOfUnits: container.decode(Int.self, forKey: .numberOfUnits)
        )
    }
}
