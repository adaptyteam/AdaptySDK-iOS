//
//  CornerRadius.swift
//  AdaptyUI
//
//  Created by Aleksei Valiano on 03.07.2023
//

import Foundation

extension AdaptyUI {
    package struct CornerRadius {
        package let topLeft: Double
        package let topRight: Double
        package let bottomRight: Double
        package let bottomLeft: Double
    }
}

extension AdaptyUI.CornerRadius {
    package static let zero = AdaptyUI.CornerRadius(same: 0.0)
    package init(same value: Double) {
        self.init(topLeft: value, topRight: value, bottomRight: value, bottomLeft: value)
    }

    package var isZeroRadius: Bool {
        topLeft == 0.0 && topRight == 0.0 && bottomRight == 0.0 && bottomLeft == 0.0
    }

    package var isSameRadius: Bool {
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

    package init(from decoder: Decoder) throws {
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
