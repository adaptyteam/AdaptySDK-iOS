//
//  Schema.Box.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 28.03.2024
//

import Foundation

extension Schema {
    struct Box: Sendable {
        let width: VC.Box.Length?
        let height: VC.Box.Length?
        let horizontalAlignment: VC.HorizontalAlignment
        let verticalAlignment: VC.VerticalAlignment
        let content: Schema.Element?
    }
}

extension Schema.Localizer {
    func box(_ from: Schema.Box) throws -> VC.Box {
        try .init(
            width: from.width,
            height: from.height,
            horizontalAlignment: from.horizontalAlignment,
            verticalAlignment: from.verticalAlignment,
            content: from.content.map(element)
        )
    }
}

extension Schema.Box: Codable {
    enum CodingKeys: String, CodingKey {
        case width
        case height
        case horizontalAlignment = "h_align"
        case verticalAlignment = "v_align"
        case content
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            width: try? container.decodeIfPresent(VC.Box.Length.self, forKey: .width),
            height: try? container.decodeIfPresent(VC.Box.Length.self, forKey: .height),
            horizontalAlignment: container.decodeIfPresent(VC.HorizontalAlignment.self, forKey: .horizontalAlignment) ?? VC.Box.defaultHorizontalAlignment,
            verticalAlignment: container.decodeIfPresent(VC.VerticalAlignment.self, forKey: .verticalAlignment) ?? VC.Box.defaultVerticalAlignment,
            content: container.decodeIfPresent(Schema.Element.self, forKey: .content)
        )
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(width, forKey: .width)
        try container.encodeIfPresent(height, forKey: .height)
        if horizontalAlignment != .center {
            try container.encode(horizontalAlignment, forKey: .horizontalAlignment)
        }
        if verticalAlignment != .center {
            try container.encode(verticalAlignment, forKey: .verticalAlignment)
        }
        try container.encodeIfPresent(content, forKey: .content)
    }
}

extension VC.Box.Length: Codable {
    enum CodingKeys: String, CodingKey {
        case min
        case max
        case shrink
        case fillMax = "fill_max"
    }

    package init(from decoder: Decoder) throws {
        if let value = try? decoder.singleValueContainer().decode(VC.Unit.self) {
            self = .fixed(value)
        } else {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            if let value = try container.decodeIfPresent(Bool.self, forKey: .fillMax), value {
                self = .fillMax
            } else if let value = try container.decodeIfPresent(VC.Unit.self, forKey: .min) {
                self = try .flexible(min: value, max: container.decodeIfPresent(VC.Unit.self, forKey: .max))
            } else if let value = try container.decodeIfPresent(VC.Unit.self, forKey: .shrink) {
                self = try .shrinkable(min: value, max: container.decodeIfPresent(VC.Unit.self, forKey: .max))
            } else if let value = try container.decodeIfPresent(VC.Unit.self, forKey: .max) {
                self = .flexible(min: nil, max: value)
            } else {
                throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: container.codingPath, debugDescription: "don't found unknown properties"))
            }
        }
    }

    package func encode(to encoder: any Encoder) throws {
        switch self {
        case let .fixed(unit):
            try unit.encode(to: encoder)
        case let .flexible(min, max):
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encodeIfPresent(min, forKey: .min)
            try container.encodeIfPresent(max, forKey: .max)
        case let .shrinkable(min, max):
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(min, forKey: .shrink)
            try container.encodeIfPresent(max, forKey: .max)
        case .fillMax:
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(true, forKey: .fillMax)
        }
    }
}
