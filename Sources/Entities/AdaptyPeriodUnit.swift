//
//  AdaptyPeriodUnit.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 20.10.2022.
//

import Foundation
import StoreKit

public enum AdaptyPeriodUnit: UInt {
    case day
    case week
    case month
    case year
    case unknown
}

extension AdaptyPeriodUnit {
    init(unit: SK1Product.PeriodUnit) {
        self =
            switch unit {
            case .day: .day
            case .week: .week
            case .month: .month
            case .year: .year
            @unknown default: .unknown
            }
    }

    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
    init(unit: SK2Product.SubscriptionPeriod.Unit) {
        self =
            switch unit {
            case .day: .day
            case .week: .week
            case .month: .month
            case .year: .year
            @unknown default: .unknown
            }
    }
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

extension AdaptyPeriodUnit: Equatable, Sendable {}

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
