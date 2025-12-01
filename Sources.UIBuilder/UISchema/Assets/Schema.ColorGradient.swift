//
//  Schema.ColorGradient.swift
//  AdaptyUIBulder
//
//  Created by Aleksei Valiano on 25.11.2025.
//

import Foundation

extension Schema {
    typealias ColorGradient = VC.ColorGradient
}

extension Schema.ColorGradient {
    static func assetType(_ type: String) -> Bool {
        Kind(rawValue: type) != nil
    }
}

extension Schema.ColorGradient: Codable {
    private struct Points: Codable {
        let x0: Double
        let y0: Double
        let x1: Double
        let y1: Double

        init(start: Schema.Point, end: Schema.Point) {
            x0 = start.x
            y0 = start.y
            x1 = end.x
            y1 = end.y
        }

        var start: Schema.Point {
            Schema.Point(x: x0, y: y0)
        }

        var end: Schema.Point {
            Schema.Point(x: x1, y: y1)
        }
    }

    private enum CodingKeys: String, CodingKey {
        case points
        case items = "values"
        case kind = "type"
        case customId = "custom_id"
    }

    package init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        items = try container.decode([Item].self, forKey: .items)
        let points = try container.decode(Points.self, forKey: .points)
        start = points.start
        end = points.end
        customId = try container.decodeIfPresent(String.self, forKey: .customId)
        kind = try container.decode(Kind.self, forKey: .kind)
    }

    package func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(items, forKey: .items)
        try container.encode(Points(start: start, end: end), forKey: .points)
        try container.encodeIfPresent(customId, forKey: .customId)
        try container.encode(kind, forKey: .kind)
    }
}
