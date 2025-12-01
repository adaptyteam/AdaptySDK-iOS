//
//  Schema.CornerRadius.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 26.11.2025.
//

import Foundation

extension Schema {
    typealias CornerRadius = VC.CornerRadius
}

extension Schema.CornerRadius: Codable {
    enum CodingKeys: String, CodingKey {
        case topLeading = "top_leading"
        case topTrailing = "top_trailing"
        case bottomTrailing = "bottom_trailing"
        case bottomLeading = "bottom_leading"
    }

    package init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let value = try? container.decode(Double.self) {
            self.init(same: value)
        } else if let values = try? container.decode([Double].self) {
            switch values.count {
            case 0: self.init(same: .zero)
            case 1: self.init(same: values[0])
            case 2: self.init(topLeading: values[0], topTrailing: values[1], bottomTrailing: .zero, bottomLeading: .zero)
            case 3: self.init(topLeading: values[0], topTrailing: values[1], bottomTrailing: values[2], bottomLeading: .zero)
            default: self.init(topLeading: values[0], topTrailing: values[1], bottomTrailing: values[2], bottomLeading: values[3])
            }
        } else {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            try self.init(
                topLeading: container.decodeIfPresent(Double.self, forKey: .topLeading) ?? .zero,
                topTrailing: container.decodeIfPresent(Double.self, forKey: .topTrailing) ?? .zero,
                bottomTrailing: container.decodeIfPresent(Double.self, forKey: .bottomTrailing) ?? .zero,
                bottomLeading: container.decodeIfPresent(Double.self, forKey: .bottomLeading) ?? .zero
            )
        }
    }

    package func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        if !topLeading.isZero { try container.encode(topLeading, forKey: .topLeading) }
        if !topTrailing.isZero { try container.encode(topTrailing, forKey: .topTrailing) }
        if !bottomTrailing.isZero { try container.encode(bottomTrailing, forKey: .bottomTrailing) }
        if !bottomLeading.isZero { try container.encode(bottomLeading, forKey: .bottomLeading) }
    }
}
