//
//  Schema.Animation.ScaleParameters.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 25.11.2025.
//

import Foundation

extension Schema.Animation {
    typealias ScaleParameters = VC.Animation.ScaleParameters
}

extension Schema.Animation.ScaleParameters: Codable {
    enum CodingKeys: String, CodingKey {
        case scale
        case anchor
    }

    package init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        scale = try container.decode(Schema.Animation.Range<Schema.Point>.self, forKey: .scale)
        anchor = try container.decodeIfPresent(Schema.Point.self, forKey: .anchor) ?? .center
    }

    package func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(scale, forKey: .scale)
        if anchor != .center {
            try container.encode(anchor, forKey: .anchor)
        }
    }
}
