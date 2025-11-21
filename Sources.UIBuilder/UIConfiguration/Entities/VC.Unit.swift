//
//  VC.Unit.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 27.03.2024
//

import Foundation

package extension VC {
    enum Unit: Sendable {
        package static let zero = Unit.point(0.0)
        case point(Double)
        case screen(Double)
        case safeArea(SafeArea)
    }
}

extension VC.Unit: Hashable {
    package func hash(into hasher: inout Hasher) {
        switch self {
        case let .point(value):
            hasher.combine(1)
            hasher.combine(value)
        case let .screen(value):
            hasher.combine(2)
            hasher.combine(value)
        case let .safeArea(value):
            hasher.combine(3)
            hasher.combine(value)
        }
    }

    var isZero: Bool {
        switch self {
        case let .point(value), let .screen(value):
            value == 0.0
        default:
            false
        }
    }

    package enum SafeArea: String {
        case start
        case end
    }
}

extension VC.Unit.SafeArea: Codable {}

extension VC.Unit: Codable {
    enum CodingKeys: String, CodingKey {
        case value
        case unit
        case point
        case safeArea = "safe_area"
        case screen
    }

    package init(from decoder: Decoder) throws {
        if let points = try? decoder.singleValueContainer().decode(Double.self) {
            self = .point(points)
        } else {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            if let value = try container.decodeIfPresent(Double.self, forKey: .screen) {
                self = .screen(value)
            } else if let value = try container.decodeIfPresent(Double.self, forKey: .point) {
                self = .point(value)
            } else if let value = try container.decodeIfPresent(SafeArea.self, forKey: .safeArea) {
                self = .safeArea(value)
            } else {
                let value = try container.decode(Double.self, forKey: .value)
                let unit = try container.decodeIfPresent(String.self, forKey: .unit)
                switch unit {
                case CodingKeys.screen.rawValue:
                    self = .screen(value)
                case CodingKeys.point.rawValue, nil:
                    self = .point(value)
                default:
                    throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: container.codingPath + [CodingKeys.unit], debugDescription: "usupport value: \(unit ?? "nil")"))
                }
            }
        }
    }

    package func encode(to encoder: any Encoder) throws {
        switch self {
        case let .point(value):
            try value.encode(to: encoder)
        case let .screen(value):
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(value, forKey: .screen)
        case let .safeArea(value):
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(value, forKey: .safeArea)
        }
    }
}
