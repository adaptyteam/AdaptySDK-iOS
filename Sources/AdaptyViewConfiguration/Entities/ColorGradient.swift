//
//  ColorGradient.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 29.06.2023
//

import Foundation

package extension AdaptyViewConfiguration {
    struct ColorGradient: CustomAsset, Hashable, Sendable {
        package let customId: String?
        package let kind: Kind
        package let start: Point
        package let end: Point
        package let items: [Item]
    }
}

package extension AdaptyViewConfiguration.ColorGradient {
    struct Item: Hashable, Sendable {
        package let color: AdaptyViewConfiguration.Color
        package let p: Double
    }

    enum Kind {
        case linear
        case conic
        case radial
    }
}

#if DEBUG
    package extension AdaptyViewConfiguration.ColorGradient {
        static func create(
            customId: String? = nil,
            kind: AdaptyViewConfiguration.ColorGradient.Kind,
            start: AdaptyViewConfiguration.Point,
            end: AdaptyViewConfiguration.Point,
            items: [AdaptyViewConfiguration.ColorGradient.Item]
        ) -> Self {
            .init(
                customId: customId,
                kind: kind,
                start: start,
                end: end,
                items: items
            )
        }
    }

    package extension AdaptyViewConfiguration.ColorGradient.Item {
        static func create(
            color: AdaptyViewConfiguration.Color,
            p: Double
        ) -> Self {
            .init(
                color: color,
                p: p
            )
        }
    }
#endif

extension AdaptyViewConfiguration.ColorGradient: Codable {
    static func assetType(_ type: String) -> Bool {
        ContentType(rawValue: type) != nil
    }

    private enum ContentType: String, Sendable {
        case colorLinearGradient = "linear-gradient"
        case colorRadialGradient = "radial-gradient"
        case colorConicGradient = "conic-gradient"
    }

    private struct Points: Codable {
        let x0: Double
        let y0: Double
        let x1: Double
        let y1: Double

        init(start: AdaptyViewConfiguration.Point, end: AdaptyViewConfiguration.Point) {
            x0 = start.x
            y0 = start.y
            x1 = end.x
            y1 = end.y
        }

        var start: AdaptyViewConfiguration.Point {
            AdaptyViewConfiguration.Point(x: x0, y: y0)
        }

        var end: AdaptyViewConfiguration.Point {
            AdaptyViewConfiguration.Point(x: x1, y: y1)
        }
    }

    private enum CodingKeys: String, CodingKey {
        case points
        case items = "values"
        case type
        case customId = "custom_id"
    }

    package init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        items = try container.decode([Item].self, forKey: .items)
        let points = try container.decode(Points.self, forKey: .points)
        start = points.start
        end = points.end

        customId = try container.decodeIfPresent(String.self, forKey: .customId)
        kind =
            switch try container.decode(String.self, forKey: .type) {
            case AdaptyViewConfiguration.ColorGradient.ContentType.colorRadialGradient.rawValue:
                .radial
            case AdaptyViewConfiguration.ColorGradient.ContentType.colorConicGradient.rawValue:
                .conic
            default:
                .linear
            }
    }

    package func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(items, forKey: .items)
        try container.encode(Points(start: start, end: end), forKey: .points)

        try container.encodeIfPresent(customId, forKey: .customId)

        switch kind {
        case .radial:
            try container.encode(AdaptyViewConfiguration.ColorGradient.ContentType.colorRadialGradient.rawValue, forKey: .type)
        case .conic:
            try container.encode(AdaptyViewConfiguration.ColorGradient.ContentType.colorConicGradient.rawValue, forKey: .type)
        case .linear:
            try container.encode(AdaptyViewConfiguration.ColorGradient.ContentType.colorLinearGradient.rawValue, forKey: .type)
        }
    }
}

extension AdaptyViewConfiguration.ColorGradient.Item: Codable {
    enum CodingKeys: String, CodingKey {
        case color
        case p
    }

    package init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        color = try container.decode(AdaptyViewConfiguration.Color.self, forKey: .color)
        p = try container.decode(Double.self, forKey: .p)
    }

    package func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(color, forKey: .color)
        try container.encode(p, forKey: .p)
    }
}
