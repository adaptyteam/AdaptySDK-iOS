//
//  AdaptySubscriptionPeriod.Unit.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 20.10.2022.
//

import Foundation

public extension AdaptySubscriptionPeriod {
    enum Unit: UInt, Sendable, Hashable {
        case day
        case week
        case month
        case year
        case unknown
    }
}

extension AdaptySubscriptionPeriod.Unit: CustomStringConvertible {
    public var description: String { encodedValue }
}

extension AdaptySubscriptionPeriod.Unit: Codable {
    fileprivate enum CodingValues: String {
        case day
        case week
        case month
        case year
        case unknown
    }

    public init(from decoder: Decoder) throws {
        let value = try CodingValues(rawValue: decoder.singleValueContainer().decode(String.self))
        self =
            switch value {
            case .day: .day
            case .week: .week
            case .month: .month
            case .year: .year
            default: .unknown
            }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(encodedValue)
    }

    var encodedValue: String {
        let value: CodingValues =
            switch self {
            case .day: .day
            case .week: .week
            case .month: .month
            case .year: .year
            case .unknown: .unknown
            }

        return value.rawValue
    }
}
