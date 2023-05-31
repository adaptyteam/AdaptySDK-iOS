//
//  AdaptyPeriodUnit.swift
//  Adapty
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
    @available(iOS 11.2, macOS 10.13.2, *)
    public init(unit: SKProduct.PeriodUnit) {
        switch unit {
        case .day:
            self = .day
        case .week:
            self = .week
        case .month:
            self = .month
        case .year:
            self = .year
        @unknown default:
            self = .unknown
        }
    }

    @available(iOS 15.0, tvOS 15.0, watchOS 8.0, macOS 12.0, *)
    public init(unit: Product.SubscriptionPeriod.Unit) {
        switch unit {
        case .day:
            self = .day
        case .week:
            self = .week
        case .month:
            self = .month
        case .year:
            self = .year
        @unknown default:
            self = .unknown
        }
    }
    
    @available(iOS 11.2, macOS 10.13.2, *)
    public init(unit: SKProduct.PeriodUnit?) {
        guard let unit = unit else {
            self = .unknown
            return
        }
        self.init(unit: unit)
    }
}

extension AdaptyPeriodUnit: CustomStringConvertible {
    public var description: String {
        let value: CodingValues
        switch self {
        case .day: value = .day
        case .week: value = .week
        case .month: value = .month
        case .year: value = .year
        case .unknown: value = .unknown
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
        let value = CodingValues(rawValue: try decoder.singleValueContainer().decode(String.self))
        switch value {
        case .day: self = .day
        case .week: self = .week
        case .month: self = .month
        case .year: self = .year
        default: self = .unknown
        }
    }

    public func encode(to encoder: Encoder) throws {
        let value: CodingValues
        switch self {
        case .day: value = .day
        case .week: value = .week
        case .month: value = .month
        case .year: value = .year
        case .unknown: value = .unknown
        }
        var container = encoder.singleValueContainer()
        try container.encode(value.rawValue)
    }
}
