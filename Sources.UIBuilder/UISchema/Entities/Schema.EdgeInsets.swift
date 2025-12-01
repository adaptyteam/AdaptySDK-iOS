//
//  Schema.EdgeInsets.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 26.11.2025.
//

import Foundation

extension Schema {
    typealias EdgeInsets = VC.EdgeInsets
}

extension Schema.EdgeInsets: Codable {
    enum CodingKeys: String, CodingKey {
        case top
        case leading
        case trailing
        case bottom
    }

    package init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let value = try? container.decode(Schema.Unit.self) {
            self.init(same: value)
        } else if let values = try? container.decode([Schema.Unit].self) {
            switch values.count {
            case 0: self.init(same: .zero)
            case 1: self.init(same: values[0])
            case 2: self.init(leading: values[1], top: values[0], trailing: values[1], bottom: values[0])
            case 3: self.init(leading: values[0], top: values[1], trailing: values[2], bottom: .zero)
            default: self.init(leading: values[0], top: values[1], trailing: values[2], bottom: values[3])
            }
        } else {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            try self.init(
                leading: container.decodeIfPresent(Schema.Unit.self, forKey: .leading) ?? .zero,
                top: container.decodeIfPresent(Schema.Unit.self, forKey: .top) ?? .zero,
                trailing: container.decodeIfPresent(Schema.Unit.self, forKey: .trailing) ?? .zero,
                bottom: container.decodeIfPresent(Schema.Unit.self, forKey: .bottom) ?? .zero
            )
        }
    }

    package func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        if case let .point(value) = leading, value == 0 {} else
        { try container.encode(leading, forKey: .leading) }

        if case let .point(value) = top, value == 0 {} else
        { try container.encode(leading, forKey: .top) }

        if case let .point(value) = trailing, value == 0 {} else
        { try container.encode(leading, forKey: .trailing) }

        if case let .point(value) = bottom, value == 0 {} else
        { try container.encode(leading, forKey: .bottom) }
    }
}
