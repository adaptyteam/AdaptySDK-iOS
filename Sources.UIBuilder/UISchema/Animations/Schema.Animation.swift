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

extension Schema.Animation: Decodable {
    enum CodingKeys: String, CodingKey {
        case type
        case interpolator

        case opacity
        case offset
        case angle
        case anchor
        case color
        case blurRadius = "blur_radius"
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
        case innerShadow = "inner_shadow"
        case blur
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let typeName = try container.decode(String.self, forKey: .type)
        let kind: Schema.Animation.Kind =
            switch Types(rawValue: typeName) {
            case nil:
                throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: "Unknown animation type with name \(typeName)'"))
            case .fade:
                .opacity(.init(start: 0.0, end: 1.0))
            case .opacity:
                try .opacity(
                    container.decodeIfPresent(Range<Double>.self, forKey: .opacity) ?? .init(start: 0.0, end: 1.0)
                )
            case .offset:
                try .offset(
                    container.decode(Range<Schema.Offset>.self, forKey: .offset)
                )
            case .rotation:
                try .rotation(.init(from: decoder))
            case .scale:
                try .scale(.init(from: decoder))
            case .box:
                try .box(.init(from: decoder))
            case .background:
                try .background(
                    container.decode(Range<Schema.AssetReference>.self, forKey: .color)
                )
            case .border:
                try .border(.init(from: decoder))
            case .shadow:
                try .shadow(.init(from: decoder))
            case .innerShadow:
                try .innerShadow(.init(from: decoder))
            case .blur:
                try .blur(
                    container.decode(Range<Double>.self, forKey: .blurRadius)
                )
            }

        try self.init(
            timeline: .init(from: decoder),
            kind: kind
        )
    }
}

