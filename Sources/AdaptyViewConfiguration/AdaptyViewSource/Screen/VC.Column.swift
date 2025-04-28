//
//  VC.Column.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 28.03.2024
//

import Foundation

extension AdaptyViewSource {
    struct Column: Sendable, Hashable {
        let spacing: Double
        let items: [GridItem]
    }
}

extension AdaptyViewSource.Localizer {
    func column(_ from: AdaptyViewSource.Column) throws -> AdaptyViewConfiguration.Column {
        try .init(
            spacing: from.spacing,
            items: from.items.map(gridItem)
        )
    }
}

extension AdaptyViewSource.Column: Decodable {
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
