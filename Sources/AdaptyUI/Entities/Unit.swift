//
//  Unit.swift
//  AdaptyUI
//
//  Created by Aleksei Valiano on 27.03.2024
//

import Foundation

extension AdaptyUI {
    package enum Unit: Sendable {
        case point(Double)
        case screen(Double)
        case safeArea(SafeArea)
    }
}

extension AdaptyUI.Unit: Hashable {
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

extension AdaptyUI.Unit.SafeArea: Decodable {}

extension AdaptyUI.Unit: Decodable {
    enum CodingKeys: String, CodingKey {
        case value
        case unit
        case point
        case safeArea = "safe_area"
        case screen
    }

    package init(from decoder: any Decoder) throws {
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
                case .some(CodingKeys.screen.rawValue):
                    self = .screen(value)
                case .some(CodingKeys.point.rawValue), .none:
                    self = .point(value)
                default:
                    throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: container.codingPath + [CodingKeys.unit], debugDescription: "usupport value: \(unit ?? "null")"))
                }
            }
        }
    }
}
