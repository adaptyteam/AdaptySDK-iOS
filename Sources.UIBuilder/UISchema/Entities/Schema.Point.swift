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

extension Schema.Point {
    static let zero = Self(x: 0.0, y: 0.0)
    static let one = Self(x: 1.0, y: 1.0)
    static let center = Self(x: 0.5, y: 0.5)
}

extension Schema.Point: Codable {
    enum CodingKeys: String, CodingKey {
        case x
        case y
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let values = try? container.decode([Double].self) {
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

    func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode([y, x])
    }
}
