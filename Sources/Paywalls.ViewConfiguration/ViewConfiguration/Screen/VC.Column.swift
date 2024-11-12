//
//  VC.Column.swift
//  AdaptyUI
//
//  Created by Aleksei Valiano on 28.03.2024
//
//

import Foundation

extension AdaptyUICore.ViewConfiguration {
    struct Column: Sendable, Hashable {
        let spacing: Double
        let items: [GridItem]
    }
}

extension AdaptyUICore.ViewConfiguration.Localizer {
    func column(_ from: AdaptyUICore.ViewConfiguration.Column) throws -> AdaptyUICore.Column {
        try .init(
            spacing: from.spacing,
            items: from.items.map(gridItem)
        )
    }
}

extension AdaptyUICore.ViewConfiguration.Column: Decodable {
    enum CodingKeys: String, CodingKey {
        case spacing
        case items
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            spacing: container.decodeIfPresent(Double.self, forKey: .spacing) ?? 0,
            items: container.decode([AdaptyUICore.ViewConfiguration.GridItem].self, forKey: .items)
        )
    }
}
