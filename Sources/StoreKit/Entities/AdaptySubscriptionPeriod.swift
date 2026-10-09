//
//  AdaptySubscriptionPeriod.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 20.10.2022.
//

import Foundation

public struct AdaptySubscriptionPeriod: Sendable, Hashable {
    /// A unit of time that a subscription period is specified in.
    public let unit: Unit

    /// A number of period units.
    public let numberOfUnits: Int

    init(_ numberOfUnits: Int, _ unit: Unit) {
        self.unit = unit
        self.numberOfUnits = numberOfUnits
    }

}

public extension AdaptySubscriptionPeriod {
    var normalize: AdaptySubscriptionPeriod {
        switch unit {
        case .day where numberOfUnits.isMultiple(of: 7):
            .init(numberOfUnits / 7, .week)
        case .month where numberOfUnits.isMultiple(of: 12):
            .init(numberOfUnits / 12, .year)
        default:
            self
        }
    }
}

extension AdaptySubscriptionPeriod: CustomStringConvertible {
    public var description: String {
        "\(numberOfUnits) \(unit)"
    }
}

extension AdaptySubscriptionPeriod: Codable {
    enum CodingKeys: String, CodingKey {
        case unit
        case numberOfUnits = "number_of_units"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            container.decode(Int.self, forKey: .numberOfUnits),
            container.decode(Unit.self, forKey: .unit)
        )
    }
}
