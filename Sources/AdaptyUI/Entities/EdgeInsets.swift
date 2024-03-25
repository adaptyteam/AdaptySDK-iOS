//
//  EdgeInsets.swift
//
//
//  Created by Aleksei Valiano on 25.03.2024
//
//

import Foundation

extension AdaptyUI {
    public struct EdgeInsets {
        public let left: Double
        public let top: Double
        public let right: Double
        public let bottom: Double
    }
}

extension AdaptyUI.EdgeInsets {
    public static let zero = AdaptyUI.EdgeInsets(same: 0.0)
    public init(same value: Double) {
        self.init(left: value, top: value, right: value, bottom: value)
    }

    public var isZero: Bool {
        left == 0.0 && top == 0.0 && right == 0.0 && bottom == 0.0
    }

    public var isSame: Bool {
        (left == top) && (right == bottom) && (left == right)
    }
}

extension AdaptyUI.EdgeInsets: Decodable {
    enum CodingKeys: String, CodingKey {
        case top
        case left
        case right
        case bottom
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let value = try? container.decode(Double.self) {
            self.init(same: value)
        } else if let values = try? container.decode([Double].self) {
            switch values.count {
            case 0: self.init(same: 0.0)
            case 1: self.init(same: values[0])
            case 2: self.init(left: values[1], top: values[0], right: values[1], bottom: values[0])
            case 3: self.init(left: values[0], top: values[1], right: values[2], bottom: 0.0)
            default: self.init(left: values[0], top: values[1], right: values[2], bottom: values[3])
            }
        } else {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            try self.init(
                left: container.decodeIfPresent(Double.self, forKey: .left) ?? 0.0,
                top: container.decodeIfPresent(Double.self, forKey: .top) ?? 0.0,
                right: container.decodeIfPresent(Double.self, forKey: .right) ?? 0.0,
                bottom: container.decodeIfPresent(Double.self, forKey: .bottom) ?? 0.0
            )
        }
    }
}
