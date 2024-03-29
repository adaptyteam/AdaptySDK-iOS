//
//  CornerRadius.swift
//  AdaptyUI
//
//  Created by Aleksei Valiano on 03.07.2023
//

import Foundation

extension AdaptyUI {
    public struct CornerRadius {
        public let topLeft: Double
        public let topRight: Double
        public let bottomRight: Double
        public let bottomLeft: Double
    }
}

extension AdaptyUI.CornerRadius {
    public static let zero = AdaptyUI.CornerRadius(same: 0.0)
    public init(same value: Double) {
        self.init(topLeft: value, topRight: value, bottomRight: value, bottomLeft: value)
    }

    public var isZeroRadius: Bool {
        topLeft == 0.0 && topRight == 0.0 && bottomRight == 0.0 && bottomLeft == 0.0
    }

    public var isSameRadius: Bool {
        (topLeft == topRight) && (bottomLeft == bottomRight) && (topLeft == bottomLeft)
    }
}

extension AdaptyUI.CornerRadius: Decodable {
    enum CodingKeys: String, CodingKey {
        case topLeft = "tl"
        case topRight = "tr"
        case bottomRight = "br"
        case bottomLeft = "bl"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let value = try? container.decode(Double.self) {
            self.init(same: value)
        } else if let values = try? container.decode([Double].self) {
            switch values.count {
            case 0: self.init(same: 0.0)
            case 1: self.init(same: values[0])
            case 2: self.init(topLeft: values[0], topRight: values[1], bottomRight: 0.0, bottomLeft: 0.0)
            case 3: self.init(topLeft: values[0], topRight: values[1], bottomRight: values[2], bottomLeft: 0.0)
            default: self.init(topLeft: values[0], topRight: values[1], bottomRight: values[2], bottomLeft: values[3])
            }
        } else {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            try self.init(
                topLeft: container.decodeIfPresent(Double.self, forKey: .topLeft) ?? 0.0,
                topRight: container.decodeIfPresent(Double.self, forKey: .topRight) ?? 0.0,
                bottomRight: container.decodeIfPresent(Double.self, forKey: .bottomRight) ?? 0.0,
                bottomLeft: container.decodeIfPresent(Double.self, forKey: .bottomLeft) ?? 0.0
            )
        }
    }
}
