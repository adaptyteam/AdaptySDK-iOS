//
//  Offset.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 25.03.2024
//

import Foundation

package extension AdaptyViewConfiguration {
    struct Offset: Sendable, Hashable {
        package let x: Unit
        package let y: Unit
    }
}

package extension AdaptyViewConfiguration.Offset {
    static let zero = AdaptyViewConfiguration.Offset(x: .zero, y: .zero)
    static let one = AdaptyViewConfiguration.Offset(x: .point(1.0), y: .point(1.0))

    var isZero: Bool {
        x.isZero && y.isZero
    }
}

#if DEBUG
package extension AdaptyViewConfiguration.Offset {
    static func create(
        x: AdaptyViewConfiguration.Unit = .zero,
        y: AdaptyViewConfiguration.Unit = .zero
    ) -> Self {
        .init(
            x: x,
            y: y
        )
    }
}
#endif

extension AdaptyViewConfiguration.Offset: Codable {
    enum CodingKeys: String, CodingKey {
        case x
        case y
    }

    package init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let value = try? container.decode(AdaptyViewConfiguration.Unit.self) {
            self.init(x: .zero, y: value)
        } else if let values = try? container.decode([AdaptyViewConfiguration.Unit].self) {
            switch values.count {
            case 0: self.init(x: .zero, y: .zero)
            case 1: self.init(x: .zero, y: values[0])
            default: self.init(x: values[1], y: values[0])
            }
        } else {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            try self.init(
                x: container.decodeIfPresent(AdaptyViewConfiguration.Unit.self, forKey: .x) ?? .zero,
                y: container.decodeIfPresent(AdaptyViewConfiguration.Unit.self, forKey: .y) ?? .zero
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
