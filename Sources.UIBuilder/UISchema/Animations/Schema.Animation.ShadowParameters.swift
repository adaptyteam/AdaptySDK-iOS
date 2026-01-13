//
//  Schema.Animation.ShadowParameters.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 04.04.2025.
//

import Foundation

extension Schema.Animation.ShadowParameters: Codable {
    enum CodingKeys: String, CodingKey {
        case color
        case blurRadius = "blur_radius"
        case offset
    }

    package init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        color = try container.decodeIfPresent(Schema.Animation.Range<Schema.AssetReference>.self, forKey: .color)
        blurRadius = try container.decodeIfPresent(Schema.Animation.Range<Double>.self, forKey: .blurRadius)
        offset = try container.decodeIfPresent(Schema.Animation.Range<Schema.Offset>.self, forKey: .offset)

        if color == nil, blurRadius == nil, offset == nil {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "The color, blur_radius, and offset parameters cannot be absent at the same time."))
        }
    }

    package func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(color, forKey: .color)
        try container.encodeIfPresent(blurRadius, forKey: .blurRadius)
        try container.encodeIfPresent(offset, forKey: .offset)
    }
}
