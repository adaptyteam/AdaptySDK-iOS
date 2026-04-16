//
//  Schema.Animation.RotationParameters.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 25.11.2025.
//

import Foundation

extension Schema.Animation.RotationParameters: Decodable {
    enum CodingKeys: String, CodingKey {
        case angle
        case anchor
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        angle = try container.decode(Schema.Animation.Range<Double>.self, forKey: .angle)
        anchor = try container.decodeIfPresent(Schema.Point.self, forKey: .anchor) ?? .center
    }
}

