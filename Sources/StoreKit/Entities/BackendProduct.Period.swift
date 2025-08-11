//
//  BackendProduct.Period.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 24.07.2025.
//

import Foundation

package extension BackendProduct {
    enum Period: Sendable {
        case weekly
        case monthly
        case twoMonths
        case trimonthly
        case semiannual
        case annual
        case lifetime
        case consumable
        case nonSubscriptions
        case uncategorised(String?)
    }
}

extension BackendProduct.Period {
    func expiresAt(startedAt: Date) -> Date? {
        let calendar = {
            var calendar = Calendar(identifier: .gregorian)
            if let timeZone = TimeZone(abbreviation: "UTC") {
                calendar.timeZone = timeZone
            }
            return calendar
        }
        return switch self {
        case .weekly: calendar().date(byAdding: .day, value: 7, to: startedAt)
        case .monthly: calendar().date(byAdding: .month, value: 1, to: startedAt)
        case .twoMonths: calendar().date(byAdding: .month, value: 2, to: startedAt)
        case .trimonthly: calendar().date(byAdding: .month, value: 3, to: startedAt)
        case .semiannual: calendar().date(byAdding: .month, value: 6, to: startedAt)
        case .annual: calendar().date(byAdding: .year, value: 1, to: startedAt)
        default: nil
        }
    }
}

extension BackendProduct.Period: Hashable {}

extension BackendProduct.Period: CustomStringConvertible {
    package init(rawValue: String) {
        self = switch rawValue {
        case "weekly": .weekly
        case "monthly": .monthly
        case "two_months": .twoMonths
        case "trimonthly": .trimonthly
        case "semiannual": .semiannual
        case "annual": .annual
        case "lifetime": .lifetime
        case "consumable": .consumable
        case "nonsubscriptions": .nonSubscriptions
        case "uncategorised": .uncategorised(nil)
        default: .uncategorised(rawValue)
        }
    }

    package var rawValue: String {
        switch self {
        case .weekly: "weekly"
        case .monthly: "monthly"
        case .twoMonths: "two_months"
        case .trimonthly: "trimonthly"
        case .semiannual: "semiannual"
        case .annual: "annual"
        case .lifetime: "lifetime"
        case .consumable: "consumable"
        case .nonSubscriptions: "nonsubscriptions"
        case .uncategorised(let value): value ?? "uncategorised"
        }
    }

    package var description: String { rawValue }
}

extension BackendProduct.Period: Codable {
    package init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        try self.init(rawValue: container.decode(String.self))
    }

    package func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}
