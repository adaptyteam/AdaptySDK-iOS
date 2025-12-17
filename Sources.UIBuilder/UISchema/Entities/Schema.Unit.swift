//
//  Schema.Unit.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 25.11.2025.
//

extension Schema {
    typealias Unit = VC.Unit
}

package extension Schema.Unit {
    static let zero = Self.point(0.0)
}

extension Schema.Unit: Codable {
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
