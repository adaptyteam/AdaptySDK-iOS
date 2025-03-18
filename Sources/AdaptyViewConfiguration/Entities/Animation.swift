//
//  Animation.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 16.01.2024
//

import Foundation

package extension AdaptyViewConfiguration {
    enum Animation: Sendable {
        case opacity(Parameters)
        case offsetX(Parameters)
        case offsetY(Parameters)

        case rotation(Parameters)
        case scale(Parameters)
        case width(Parameters)
        case height(Parameters)

    }
}

extension AdaptyViewConfiguration.Animation: Hashable {
    package func hash(into hasher: inout Hasher) {
        switch self {
        case let .opacity(params):
            hasher.combine(1)
            hasher.combine(params)
        case let .offsetX(params):
            hasher.combine(2)
            hasher.combine(params)
        case let .offsetY(params):
            hasher.combine(3)
            hasher.combine(params)
        case let .rotation(params):
            hasher.combine(4)
            hasher.combine(params)
        case let .scale(params):
            hasher.combine(5)
            hasher.combine(params)
        case let .width(params):
            hasher.combine(6)
            hasher.combine(params)
        case let .height(params):
            hasher.combine(7)
            hasher.combine(params)
        }
    }
}

extension AdaptyViewConfiguration.Animation: Codable {
    enum CodingKeys: String, CodingKey {
        case type
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
        case .fade, .opacity:
            self = try .opacity(AdaptyViewConfiguration.Animation.Parameters(from: decoder))
        case .offsetX:
            self = try .offsetX(AdaptyViewConfiguration.Animation.Parameters(from: decoder))
        case .offsetY:
            self = try .offsetY(AdaptyViewConfiguration.Animation.Parameters(from: decoder))
        case .rotation:
            self = try .rotation(AdaptyViewConfiguration.Animation.Parameters(from: decoder))
        case .scale:
            self = try .scale(AdaptyViewConfiguration.Animation.Parameters(from: decoder))
        case .width:
            self = try .width(AdaptyViewConfiguration.Animation.Parameters(from: decoder))
        case .height:
            self = try .height(AdaptyViewConfiguration.Animation.Parameters(from: decoder))
        }
    }

    package func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case let .opacity(params):
            try container.encode(Types.opacity.rawValue, forKey: .type)
            try params.encode(to: encoder)
        case let .offsetX(params):
            try container.encode(Types.offsetX.rawValue, forKey: .type)
            try params.encode(to: encoder)
        case let .offsetY(params):
            try container.encode(Types.offsetY.rawValue, forKey: .type)
            try params.encode(to: encoder)
        case let .rotation(params):
            try container.encode(Types.rotation.rawValue, forKey: .type)
            try params.encode(to: encoder)
        case let .scale(params):
            try container.encode(Types.scale.rawValue, forKey: .type)
            try params.encode(to: encoder)
        case let .width(params):
            try container.encode(Types.width.rawValue, forKey: .type)
            try params.encode(to: encoder)
        case let .height(params):
            try container.encode(Types.height.rawValue, forKey: .type)
            try params.encode(to: encoder)
        }
    }
}
