//
//  CornerRadius.swift
//  AdaptyUI
//
//  Created by Aleksei Valiano on 03.07.2023
//

import Foundation

extension AdaptyUI {
    package struct CornerRadius: Sendable, Hashable {
        static let defaultValue: Double = 0.0
        package let topLeading: Double
        package let topTrailing: Double
        package let bottomTrailing: Double
        package let bottomLeading: Double

        package init(topLeading: Double, topTrailing: Double, bottomTrailing: Double, bottomLeading: Double) {
            self.topLeading = topLeading
            self.topTrailing = topTrailing
            self.bottomTrailing = bottomTrailing
            self.bottomLeading = bottomLeading
        }
    }
}

#if DEBUG
    package extension AdaptyUI.CornerRadius {
        static func create(
            same: Double = defaultValue
        ) -> Self {
            create(topLeading: same, topTrailing: same, bottomTrailing: same, bottomLeading: same)
        }

        static func create(
            topLeading: Double = defaultValue,
            topTrailing: Double = defaultValue,
            bottomTrailing: Double = defaultValue,
            bottomLeading: Double = defaultValue
        ) -> Self {
            .init(
                topLeading: topLeading,
                topTrailing: topTrailing,
                bottomTrailing: bottomTrailing,
                bottomLeading: bottomLeading
            )
        }
    }
#endif

extension AdaptyUI.CornerRadius {
    package static let zero = AdaptyUI.CornerRadius(same: 0.0)
    package init(same value: Double) {
        self.init(topLeading: value, topTrailing: value, bottomTrailing: value, bottomLeading: value)
    }

    package var isZeroRadius: Bool {
        topLeading == 0.0 && topTrailing == 0.0 && bottomTrailing == 0.0 && bottomLeading == 0.0
    }

    package var isSameRadius: Bool {
        (topLeading == topTrailing) && (bottomLeading == bottomTrailing) && (topLeading == bottomLeading)
    }
}

extension AdaptyUI.CornerRadius: Decodable {
    enum CodingKeys: String, CodingKey {
        case topLeading = "top_leading"
        case topTrailing = "top_trailing"
        case bottomTrailing = "bottom_trailing"
        case bottomLeading = "bottom_leading"
    }

    package init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let defaultValue = AdaptyUI.CornerRadius.defaultValue

        if let value = try? container.decode(Double.self) {
            self.init(same: value)
        } else if let values = try? container.decode([Double].self) {
            switch values.count {
            case 0: self.init(same: defaultValue)
            case 1: self.init(same: values[0])
            case 2: self.init(topLeading: values[0], topTrailing: values[1], bottomTrailing: defaultValue, bottomLeading: defaultValue)
            case 3: self.init(topLeading: values[0], topTrailing: values[1], bottomTrailing: values[2], bottomLeading: defaultValue)
            default: self.init(topLeading: values[0], topTrailing: values[1], bottomTrailing: values[2], bottomLeading: values[3])
            }
        } else {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            try self.init(
                topLeading: container.decodeIfPresent(Double.self, forKey: .topLeading) ?? defaultValue,
                topTrailing: container.decodeIfPresent(Double.self, forKey: .topTrailing) ?? defaultValue,
                bottomTrailing: container.decodeIfPresent(Double.self, forKey: .bottomTrailing) ?? defaultValue,
                bottomLeading: container.decodeIfPresent(Double.self, forKey: .bottomLeading) ?? defaultValue
            )
        }
    }
}
