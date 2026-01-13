//
//  Schema.Animation.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 20.03.2025.
//

import Foundation

extension Schema {
    typealias Animation = VC.Animation
}

extension Schema.Animation: Codable {
    enum CodingKeys: String, CodingKey {
        case type
        case interpolator

        case opacity
        case offset
        case angle
        case anchor
        case color
    }

    enum Types: String {
        case fade
        case opacity
        case offset
        case rotation
        case scale
        case box
        case background
        case border
        case shadow
    }

    package init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let typeName = try container.decode(String.self, forKey: .type)
        switch Types(rawValue: typeName) {
        case nil:
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: "Unknown animation type with name \(typeName)'"))
        case .fade:
            self = try .opacity(.init(from: decoder), .init(start: 0.0, end: 1.0))
        case .opacity:
            self = try .opacity(
                .init(from: decoder),
                container.decodeIfPresent(Range<Double>.self, forKey: .opacity)
                    ?? .init(start: 0.0, end: 1.0)
            )
        case .offset:
            self = try .offset(
                .init(from: decoder),
                container.decode(Range<Schema.Offset>.self, forKey: .offset)
            )
        case .rotation:
            self = try .rotation(
                .init(from: decoder),
                .init(from: decoder)
            )
        case .scale:
            self = try .scale(.init(from: decoder), .init(from: decoder))
        case .box:
            self = try .box(.init(from: decoder), .init(from: decoder))
        case .background:
            self = try .background(
                .init(from: decoder),
                container.decode(Range<Schema.AssetReference>.self, forKey: .color)
            )
        case .border:
            self = try .border(.init(from: decoder), .init(from: decoder))
        case .shadow:
            self = try .shadow(.init(from: decoder), .init(from: decoder))
        }
    }

    package func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case let .opacity(timeline, value):
            try container.encode(Types.opacity.rawValue, forKey: .type)
            try value.encode(to: encoder)
            try timeline.encode(to: encoder)
        case let .offset(timeline, value):
            try container.encode(Types.offset.rawValue, forKey: .type)
            try value.encode(to: encoder)
            try timeline.encode(to: encoder)
        case let .rotation(timeline, value):
            try container.encode(Types.rotation.rawValue, forKey: .type)
            try value.encode(to: encoder)
            try timeline.encode(to: encoder)
        case let .scale(timeline, value):
            try container.encode(Types.scale.rawValue, forKey: .type)
            try value.encode(to: encoder)
            try timeline.encode(to: encoder)
        case let .box(timeline, value):
            try container.encode(Types.box.rawValue, forKey: .type)
            try value.encode(to: encoder)
            try timeline.encode(to: encoder)
        case let .background(timeline, value):
            try container.encode(Types.background.rawValue, forKey: .type)
            try value.encode(to: encoder)
            try timeline.encode(to: encoder)
        case let .border(timeline, value):
            try container.encode(Types.border.rawValue, forKey: .type)
            try value.encode(to: encoder)
            try timeline.encode(to: encoder)
        case let .shadow(timeline, value):
            try container.encode(Types.shadow.rawValue, forKey: .type)
            try value.encode(to: encoder)
            try timeline.encode(to: encoder)
        }
    }
}
