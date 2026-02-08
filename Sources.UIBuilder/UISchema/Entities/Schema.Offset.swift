//
//  Schema.Offset.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 25.11.2025.
//

extension Schema {
    typealias Offset = VC.Offset
}

package extension Schema.Offset {
    static let zero = Self(x: .zero, y: .zero)
    static let one = Self(x: .point(1.0), y: .point(1.0))
}

extension Schema.Offset: Codable {
    enum CodingKeys: String, CodingKey {
        case x
        case y
    }

    package init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let value = try? container.decode(Schema.Unit.self) {
            self.init(x: .zero, y: value)
        } else if let values = try? container.decode([Schema.Unit].self) {
            switch values.count {
            case 0: self.init(x: .zero, y: .zero)
            case 1: self.init(x: .zero, y: values[0])
            default: self.init(x: values[1], y: values[0])
            }
        } else {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            try self.init(
                x: container.decodeIfPresent(Schema.Unit.self, forKey: .x) ?? .zero,
                y: container.decodeIfPresent(Schema.Unit.self, forKey: .y) ?? .zero
            )
        }
    }

    package func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        if case .point(0) = x {
            try container.encode(y)
        } else {
            try container.encode([y, x])
        }
    }
}
