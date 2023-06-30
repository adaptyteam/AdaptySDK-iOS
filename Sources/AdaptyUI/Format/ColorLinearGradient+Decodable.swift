//
//  ColorLinearGradient+Decodable.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 29.06.2023
//

import Foundation

extension AdaptyUI.ColorLinearGradient: Decodable {
    enum CodingKeys: String, CodingKey {
        case points
        case items = "values"
    }

    struct Points: Codable {
        let x0: Double
        let y0: Double
        let x1: Double
        let y1: Double

        var start: AdaptyUI.Point {
            AdaptyUI.Point(x: x0, y: y0)
        }

        var end: AdaptyUI.Point {
            AdaptyUI.Point(x: x1, y: y1)
        }
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        items = try container.decode([Item].self, forKey: .items)
        let points = try container.decode(Points.self, forKey: .points)
        start = points.start
        end = points.end
    }
}

extension AdaptyUI.ColorLinearGradient.Item: Decodable {
    enum CodingKeys: String, CodingKey {
        case color
        case p
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        color = try container.decode(AdaptyUI.Color.self, forKey: .color)
        p = try container.decode(Double.self, forKey: .p)
    }
}
