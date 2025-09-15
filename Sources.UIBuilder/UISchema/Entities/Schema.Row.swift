//
//  Schema.Row.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 28.03.2024
//

import Foundation

extension Schema {
    struct Row: Sendable {
        let spacing: Double
        let items: [GridItem]
    }
}

extension Schema.Localizer {
    func row(_ from: Schema.Row) throws -> AdaptyUIConfiguration.Row {
        try .init(
            spacing: from.spacing,
            items: from.items.map(gridItem)
        )
    }
}

extension Schema.Row: Decodable {
    enum CodingKeys: String, CodingKey {
        case spacing
        case items
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            spacing: container.decodeIfPresent(Double.self, forKey: .spacing) ?? 0,
            items: container.decode([Schema.GridItem].self, forKey: .items)
        )
    }
}
