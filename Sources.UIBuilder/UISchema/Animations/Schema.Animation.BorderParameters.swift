//
//  Schema.Animation.BorderParameters.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 04.04.2025.
//

import Foundation

extension Schema.Animation.BorderParameters: Codable {
    enum CodingKeys: String, CodingKey {
        case color
        case thickness
    }

    package init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        color = try container.decodeIfPresent(Schema.Animation.Range<Schema.AssetReference>.self, forKey: .color)
        thickness = try container.decodeIfPresent(Schema.Animation.Range<Double>.self, forKey: .thickness)

        if color == nil, thickness == nil {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "The color and thickness parameters cannot be absent together."))
        }
    }

    package func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(color, forKey: .color)
        try container.encodeIfPresent(thickness, forKey: .thickness)
    }
}
