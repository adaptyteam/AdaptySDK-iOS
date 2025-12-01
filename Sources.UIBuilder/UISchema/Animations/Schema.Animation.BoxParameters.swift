//
//  Schema.Animation.BoxParameters.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 25.11.2025.
//

import Foundation

extension Schema.Animation {
    typealias BoxParameters = VC.Animation.BoxParameters
}

extension Schema.Animation.BoxParameters: Codable {
    enum CodingKeys: String, CodingKey {
        case width
        case height
    }

    package init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        width = try container.decodeIfPresent(Schema.Animation.Range<Schema.Unit>.self, forKey: .width)
        height = try container.decodeIfPresent(Schema.Animation.Range<Schema.Unit>.self, forKey: .height)

        if width == nil, height == nil {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "The width and height parameters cannot be absent together."))
        }
    }

    package func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(width, forKey: .width)
        try container.encodeIfPresent(height, forKey: .height)
    }
}
