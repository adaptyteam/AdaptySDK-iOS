//
//  Schema.Animation.ScaleParameters.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 25.11.2025.
//

import Foundation

extension Schema.Animation.ScaleParameters: Decodable {
    enum CodingKeys: String, CodingKey {
        case scale
        case anchor
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        scale = try container.decode(Schema.Animation.Range<Schema.Point>.self, forKey: .scale)
        anchor = try container.decodeIfPresent(Schema.Point.self, forKey: .anchor) ?? .center
    }
}
