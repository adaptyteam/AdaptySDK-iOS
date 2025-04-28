//
//  VC.Row.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 28.03.2024
//

import Foundation

extension AdaptyViewSource {
    struct Row: Sendable, Hashable {
        let spacing: Double
        let items: [GridItem]
    }
}

extension AdaptyViewSource.Localizer {
    func row(_ from: AdaptyViewSource.Row) throws -> AdaptyViewConfiguration.Row {
        try .init(
            spacing: from.spacing,
            items: from.items.map(gridItem)
        )
    }
}

extension AdaptyViewSource.Row: Decodable {
    enum CodingKeys: String, CodingKey {
        case spacing
        case items
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            spacing: container.decodeIfPresent(Double.self, forKey: .spacing) ?? 0,
            items: container.decode([AdaptyViewSource.GridItem].self, forKey: .items)
        )
    }
}
