//
//  Animation.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 16.01.2024
//

import Foundation

package extension AdaptyViewConfiguration {
    enum Animation: Sendable {
        case opacity(Timeline, DoubleValue)
        case offsetX(Timeline, UnitValue)
        case offsetY(Timeline, UnitValue)
        case rotation(Timeline, DoubleValue)
        case scale(Timeline, DoubleValue)
        case width(Timeline, UnitValue)
        case height(Timeline, UnitValue)
    }
}

extension AdaptyViewConfiguration.Animation: Hashable {
    package func hash(into hasher: inout Hasher) {
        switch self {
        case let .opacity(timeline, value):
            hasher.combine(1)
            hasher.combine(timeline)
            hasher.combine(value)
        case let .offsetX(timeline, value):
            hasher.combine(2)
            hasher.combine(timeline)
            hasher.combine(value)
        case let .offsetY(timeline, value):
            hasher.combine(3)
            hasher.combine(timeline)
            hasher.combine(value)
        case let .rotation(timeline, value):
            hasher.combine(4)
            hasher.combine(timeline)
            hasher.combine(value)
        case let .scale(timeline, value):
            hasher.combine(5)
            hasher.combine(timeline)
            hasher.combine(value)
        case let .width(timeline, value):
            hasher.combine(6)
            hasher.combine(timeline)
            hasher.combine(value)
        case let .height(timeline, value):
            hasher.combine(7)
            hasher.combine(timeline)
            hasher.combine(value)
        }
    }
}

extension AdaptyViewConfiguration.Animation: Codable {
    enum CodingKeys: String, CodingKey {
        case type
        case interpolator
    }

    enum Types: String {
        case fade
        case opacity
        case offsetX = "offset_x"
        case offsetY = "offset_y"
        case rotation
        case scale
        case width
        case height
    }

    package init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let typeName = try container.decode(String.self, forKey: .type)
        switch Types(rawValue: typeName) {
        case .none:
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: "Unknown animation type with name \(typeName)'"))
        case .fade:
            self = try .opacity(.init(from: decoder), .init(
                interpolator: (container.decodeIfPresent(AdaptyViewConfiguration.Animation.Interpolator.self, forKey: .interpolator)) ?? .default,
                start: 0.0,
                end: 1.0
            ))
        case .opacity:
            self = try .opacity(.init(from: decoder), .init(from: decoder))
        case .offsetX:
            self = try .offsetX(.init(from: decoder), .init(from: decoder))
        case .offsetY:
            self = try .offsetY(.init(from: decoder), .init(from: decoder))
        case .rotation:
            self = try .rotation(.init(from: decoder), .init(from: decoder))
        case .scale:
            self = try .scale(.init(from: decoder), .init(from: decoder))
        case .width:
            self = try .width(.init(from: decoder), .init(from: decoder))
        case .height:
            self = try .height(.init(from: decoder), .init(from: decoder))
        }
    }

    package func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case let .opacity(timeline, value):
            try container.encode(Types.opacity.rawValue, forKey: .type)
            try value.encode(to: encoder)
            try timeline.encode(to: encoder)
        case let .offsetX(timeline, value):
            try container.encode(Types.offsetX.rawValue, forKey: .type)
            try value.encode(to: encoder)
            try timeline.encode(to: encoder)
        case let .offsetY(timeline, value):
            try container.encode(Types.offsetY.rawValue, forKey: .type)
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
        case let .width(timeline, value):
            try container.encode(Types.width.rawValue, forKey: .type)
            try value.encode(to: encoder)
            try timeline.encode(to: encoder)
        case let .height(timeline, value):
            try container.encode(Types.height.rawValue, forKey: .type)
            try value.encode(to: encoder)
            try timeline.encode(to: encoder)
        }
    }
}
