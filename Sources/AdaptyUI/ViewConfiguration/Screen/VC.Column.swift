//
//  VC.Column.swift
//  AdaptyUI
//
//  Created by Aleksei Valiano on 28.03.2024
//
//

import Foundation

extension AdaptyUI.ViewConfiguration {
    struct Column {
        let spacing: Double
        let items: [GridItem]
    }
}

extension AdaptyUI.ViewConfiguration.Localizer {
    func column(_ from: AdaptyUI.ViewConfiguration.Column) throws -> AdaptyUI.Column {
        try .init(
            spacing: from.spacing,
            items: from.items.map(gridItem)
        )
    }
}

extension AdaptyUI.ViewConfiguration.Column: Decodable {
    enum CodingKeys: String, CodingKey {
        case spacing
        case items
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            spacing: container.decodeIfPresent(Double.self, forKey: .spacing) ?? 0,
            items: container.decode([AdaptyUI.ViewConfiguration.GridItem].self, forKey: .items)
        )
    }
}
