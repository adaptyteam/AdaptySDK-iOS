//
//  Schema.Point.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 25.11.2025.
//

import Foundation

extension Schema {
    typealias Point = VC.Point
}

extension Schema.Point: Codable {
    enum CodingKeys: String, CodingKey {
        case x
        case y
    }

    package init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let value = try? container.decode(Double.self) {
            self.init(x: value, y: value)
        } else if let values = try? container.decode([Double].self) {
            switch values.count {
            case 0: self.init(x: 0.0, y: 0.0)
            case 1: self.init(x: values[0], y: values[0])
            default: self.init(x: values[1], y: values[0])
            }
        } else {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            try self.init(
                x: container.decodeIfPresent(Double.self, forKey: .x) ?? 0.0,
                y: container.decodeIfPresent(Double.self, forKey: .y) ?? 0.0
            )
        }
    }

    package func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        if x == y {
            try container.encode(x)
        } else {
            try container.encode([y, x])
        }
    }
}
