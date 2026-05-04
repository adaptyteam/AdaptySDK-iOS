//
//  Schema.Scale.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 26.03.2026.
//

extension Schema {
    typealias Scale = VC.Scale
}

extension Schema.Scale {
    static let empty = Self(scale: .one, anchor: .center)
}

extension Schema.Scale: Codable {
    enum CodingKeys: String, CodingKey {
        case scale
        case anchor
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        try self.init(
            scale: container.decode(Schema.Point.self, forKey: .scale),
            anchor: container.decodeIfPresent(Schema.Point.self, forKey: .anchor) ?? .center
        )
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(scale, forKey: .scale)
        if anchor != .center {
            try container.encode(anchor, forKey: .anchor)
        }
    }
}

