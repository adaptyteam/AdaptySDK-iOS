//
//  Schema.ColorGradient.Item.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 25.11.2025.
//

import Foundation

extension Schema.ColorGradient.Item: Decodable {
    enum CodingKeys: String, CodingKey {
        case color
        case p
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        color = try container.decode(Schema.Color.self, forKey: .color)
        p = try container.decode(Double.self, forKey: .p)
    }
}
