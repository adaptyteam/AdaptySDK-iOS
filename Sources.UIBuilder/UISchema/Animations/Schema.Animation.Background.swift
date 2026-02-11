//
//  Schema.Animation.Background.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 11.02.2026.
//
import Foundation

extension Schema.Animation.Background: Codable {
    enum CodingKeys: String, CodingKey {
        case type
        case interpolator
        case color
    }

    package init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let typeName = try container.decode(String.self, forKey: .type)

        guard typeName == Schema.Animation.Types.background.rawValue else {
            throw DecodingError.dataCorrupted(.init(codingPath: container.codingPath, debugDescription: "Only background animation is available"))
        }

        try self.init(
            timeline: .init(from: decoder),
            range: container.decode(Schema.Animation.Range<Schema.AssetReference>.self, forKey: .color)
        )
    }

    package func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(Schema.Animation.Types.background.rawValue, forKey: .type)
        try range.encode(to: encoder)
        try timeline.encode(to: encoder)
    }
}
