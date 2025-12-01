//
//  Schema.Animation.RotationParameters.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 25.11.2025.
//

import Foundation

extension Schema.Animation {
    typealias RotationParameters = VC.Animation.RotationParameters
}

extension Schema.Animation.RotationParameters: Codable {
    enum CodingKeys: String, CodingKey {
        case angle
        case anchor
    }

    package init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        angle = try container.decode(Schema.Animation.Range<Double>.self, forKey: .angle)
        anchor = try container.decodeIfPresent(Schema.Point.self, forKey: .anchor) ?? .center
    }

    package func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(angle, forKey: .angle)
        if anchor != .center {
            try container.encode(anchor, forKey: .anchor)
        }
    }
}
