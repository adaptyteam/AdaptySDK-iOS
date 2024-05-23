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
        let horizontalAlignment: AdaptyUI.HorizontalAlignment
        let spacing: Double
        let items: [RowOrColumnItem]
    }
}

extension AdaptyUI.ViewConfiguration.Localizer {
    func column(_ from: AdaptyUI.ViewConfiguration.Column) -> AdaptyUI.Column {
        .init(
            horizontalAlignment: from.horizontalAlignment,
            spacing: from.spacing,
            items: from.items.map(rowOrColumnItem)
        )
    }
}

extension AdaptyUI.ViewConfiguration.Column: Decodable {
    enum CodingKeys: String, CodingKey {
        case horizontalAlignment = "h_align"
        case spacing
        case items
    }

    init(from decoder: any Decoder) throws {
        let def = AdaptyUI.Column.default
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            horizontalAlignment: container.decodeIfPresent(AdaptyUI.HorizontalAlignment.self, forKey: .horizontalAlignment) ?? def.horizontalAlignment,
            spacing: container.decodeIfPresent(Double.self, forKey: .spacing) ?? 0,
            items: container.decode([AdaptyUI.ViewConfiguration.RowOrColumnItem].self, forKey: .items)
        )
    }
}
