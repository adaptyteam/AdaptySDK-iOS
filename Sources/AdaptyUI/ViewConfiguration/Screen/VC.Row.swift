//
//  VC.Row.swift
//  AdaptyUI
//
//  Created by Aleksei Valiano on 28.03.2024
//
//

import Foundation

extension AdaptyUI.ViewConfiguration {
    struct Row {
        let verticalAlignment: AdaptyUI.VerticalAlignment
        let spacing: Double
        let items: [RowOrColumnItem]
    }

    package enum RowOrColumnItem {
        case fixed(length: AdaptyUI.Unit, content: AdaptyUI.ViewConfiguration.Element)
        case flexable(weight: Double, content: AdaptyUI.ViewConfiguration.Element)
    }
}

extension AdaptyUI.ViewConfiguration.Localizer {
    func rowOrColumnItem(_ from: AdaptyUI.ViewConfiguration.RowOrColumnItem) -> AdaptyUI.RowOrColumnItem {
        switch from {
        case let .fixed(length, content):
            .fixed(length: length, content: element(content))
        case let .flexable(weight, content):
            .flexable(weight: weight, content: element(content))
        }
    }

    func row(_ from: AdaptyUI.ViewConfiguration.Row) -> AdaptyUI.Row {
        .init(
            verticalAlignment: from.verticalAlignment,
            spacing: from.spacing,
            items: from.items.map(rowOrColumnItem)
        )
    }
}

extension AdaptyUI.ViewConfiguration.Row: Decodable {
    enum CodingKeys: String, CodingKey {
        case verticalAlignment = "v_align"
        case spacing
        case items
    }

    init(from decoder: any Decoder) throws {
        let def = AdaptyUI.Row.default
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            verticalAlignment: container.decodeIfPresent(AdaptyUI.VerticalAlignment.self, forKey: .verticalAlignment) ?? def.verticalAlignment,
            spacing: container.decodeIfPresent(Double.self, forKey: .spacing) ?? 0,
            items: container.decode([AdaptyUI.ViewConfiguration.RowOrColumnItem].self, forKey: .items)
        )
    }
}

extension AdaptyUI.ViewConfiguration.RowOrColumnItem: Decodable {
    enum CodingKeys: String, CodingKey {
        case fixed
        case flexable = "weight"
        case content
    }

    init(from decoder: any Decoder) throws {
        let conteineer = try decoder.container(keyedBy: CodingKeys.self)
        let content = try conteineer.decode(AdaptyUI.ViewConfiguration.Element.self, forKey: .content)
        if let weight = try conteineer.decodeIfPresent(Double.self, forKey: .flexable) {
            self = .flexable(weight: weight, content: content)
        } else {
            self = try .fixed(length: conteineer.decode(AdaptyUI.Unit.self, forKey: .fixed), content: content)
        }
    }
}
