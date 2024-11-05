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

    init(unit: Unit, numberOfUnits: Int) {
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
            unit: container.decode(Unit.self, forKey: .unit),
            numberOfUnits: container.decode(Int.self, forKey: .numberOfUnits)
        )
    }
}
