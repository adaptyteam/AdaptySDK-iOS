//
//  AdaptyPeriodUnit.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 20.10.2022.
//

import Foundation

public enum AdaptyPeriodUnit: UInt, Sendable, Hashable {
    case day
    case week
    case month
    case year
    case unknown
}

extension AdaptyPeriodUnit: CustomStringConvertible {
    public var description: String {
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

extension AdaptyPeriodUnit: Codable {
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
        let value: CodingValues =
            switch self {
            case .day: .day
            case .week: .week
            case .month: .month
            case .year: .year
            case .unknown: .unknown
            }
        var container = encoder.singleValueContainer()
        try container.encode(value.rawValue)
    }
}
