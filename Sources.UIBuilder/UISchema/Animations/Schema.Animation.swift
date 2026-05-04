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
        case .innerShadow:
            self = try .innerShadow(.init(from: decoder), .init(from: decoder))
        case .blur:
            self = try .blur(
                .init(from: decoder),
                container.decode(Range<Double>.self, forKey: .blurRadius)
            )
        }
    }
}

