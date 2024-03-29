//
//  Point.swift
//  AdaptyUI
//
//  Created by Aleksei Valiano on 29.06.2023
//

import Foundation

extension AdaptyUI {
    public struct Point {
        public let x: Double
        public let y: Double
    }
}

extension AdaptyUI.Point {
    public static let zero = AdaptyUI.Point(x: 0.0, y: 0.0)

    public var isZero: Bool {
        x == 0.0 && y == 0.0
    }
}

extension AdaptyUI.Point: Decodable {
    enum CodingKeys: String, CodingKey {
        case x
        case y
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let value = try? container.decode(Double.self) {
            self.init(x: 0.0, y: value)
        } else if let values = try? container.decode([Double].self) {
            switch values.count {
            case 0: self.init(x: 0.0, y: 0.0)
            case 1: self.init(x: 0.0, y: values[0])
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
}
