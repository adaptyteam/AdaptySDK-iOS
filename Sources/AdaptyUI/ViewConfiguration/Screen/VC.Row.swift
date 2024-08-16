//
//  VC.Row.swift
//  AdaptyUI
//
//  Created by Aleksei Valiano on 28.03.2024
//
//

import Foundation

extension AdaptyUI.ViewConfiguration {
    struct Row: Sendable, Hashable {
        let spacing: Double
        let items: [GridItem]
    }
}

extension AdaptyUI.ViewConfiguration.Localizer {
    func row(_ from: AdaptyUI.ViewConfiguration.Row) throws -> AdaptyUI.Row {
        try .init(
            spacing: from.spacing,
            items: from.items.map(gridItem)
        )
    }
}

extension AdaptyUI.ViewConfiguration.Row: Decodable {
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
