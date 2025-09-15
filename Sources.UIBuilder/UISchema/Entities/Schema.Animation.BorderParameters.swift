//
//  Schema.Animation.BorderParameters.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 04.04.2025.
//

import Foundation

extension Schema.Animation {
    struct BorderParameters: Sendable, Hashable {
        package let color: Schema.Animation.Range<String>?
        package let thickness: Schema.Animation.Range<Double>?
    }
}

extension Schema.Localizer {
    func animationBorderParameters(_ from: Schema.Animation.BorderParameters) throws -> AdaptyViewConfiguration.Animation.BorderParameters {
        try .init(
            color: from.color.map(animationFillingValue),
            thickness: from.thickness
        )
    }
}

extension Schema.Animation.BorderParameters: Codable {
    enum CodingKeys: String, CodingKey {
        case color
        case thickness
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        color = try container.decodeIfPresent(Schema.Animation.Range<String>.self, forKey: .color)
        thickness = try container.decodeIfPresent(Schema.Animation.Range<Double>.self, forKey: .thickness)

        if color == nil && thickness == nil {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "The color and thickness parameters cannot be absent together."))
        }
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(color, forKey: .color)
        try container.encodeIfPresent(thickness, forKey: .thickness)
    }
}
