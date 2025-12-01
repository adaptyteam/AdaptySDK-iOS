//
//  Schema.Animation.ShadowParameters.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 04.04.2025.
//

import Foundation

extension Schema.Animation {
    struct ShadowParameters: Sendable, Hashable {
        package let color: Schema.Animation.Range<String>?
        package let blurRadius: Schema.Animation.Range<Double>?
        package let offset: Schema.Animation.Range<Schema.Offset>?
    }
}

extension Schema.Localizer {
    func animationShadowParameters(_ from: Schema.Animation.ShadowParameters) throws -> VC.Animation.ShadowParameters {
        try .init(
            color: from.color.map(animationFillingValue),
            blurRadius: from.blurRadius,
            offset: from.offset
        )
    }
}

extension Schema.Animation.ShadowParameters: Codable {
    enum CodingKeys: String, CodingKey {
        case color
        case blurRadius = "blur_radius"
        case offset
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        color = try container.decodeIfPresent(Schema.Animation.Range<String>.self, forKey: .color)
        blurRadius = try container.decodeIfPresent(Schema.Animation.Range<Double>.self, forKey: .blurRadius)
        offset = try container.decodeIfPresent(Schema.Animation.Range<Schema.Offset>.self, forKey: .offset)

        if color == nil && blurRadius == nil && offset == nil {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "The color, blur_radius, and offset parameters cannot be absent at the same time."))
        }
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(color, forKey: .color)
        try container.encodeIfPresent(blurRadius, forKey: .blurRadius)
        try container.encodeIfPresent(offset, forKey: .offset)
    }
}
