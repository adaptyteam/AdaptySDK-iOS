//
//  Schema.Animation.BoxParameters.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 25.11.2025.
//

import Foundation

extension Schema.Animation.BoxParameters: Decodable {
    enum CodingKeys: String, CodingKey {
        case width
        case height
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        width = try container.decodeIfPresent(Schema.Animation.Range<Schema.Unit>.self, forKey: .width)
        height = try container.decodeIfPresent(Schema.Animation.Range<Schema.Unit>.self, forKey: .height)

        if width == nil, height == nil {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "The width and height parameters cannot be absent together."))
        }
    }
}

