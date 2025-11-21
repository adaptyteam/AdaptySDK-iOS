//
//  VC.Offset.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 25.03.2024
//

import Foundation

package extension VC {
    struct Offset: Sendable, Hashable {
        package let x: Unit
        package let y: Unit
    }
}

package extension VC.Offset {
    static let zero = VC.Offset(x: .zero, y: .zero)
    static let one = VC.Offset(x: .point(1.0), y: .point(1.0))

    var isZero: Bool {
        x.isZero && y.isZero
    }
}

#if DEBUG
package extension VC.Offset {
    static func create(
        x: VC.Unit = .zero,
        y: VC.Unit = .zero
    ) -> Self {
        .init(
            x: x,
            y: y
        )
    }
}
#endif

extension VC.Offset: Codable {
    enum CodingKeys: String, CodingKey {
        case x
        case y
    }

    package init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let value = try? container.decode(VC.Unit.self) {
            self.init(x: .zero, y: value)
        } else if let values = try? container.decode([VC.Unit].self) {
            switch values.count {
            case 0: self.init(x: .zero, y: .zero)
            case 1: self.init(x: .zero, y: values[0])
            default: self.init(x: values[1], y: values[0])
            }
        } else {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            try self.init(
                x: container.decodeIfPresent(VC.Unit.self, forKey: .x) ?? .zero,
                y: container.decodeIfPresent(VC.Unit.self, forKey: .y) ?? .zero
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
