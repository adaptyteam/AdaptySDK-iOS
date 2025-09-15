//
//  Schema.GridItem.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 28.03.2024
//

import Foundation

extension Schema {
    struct GridItem: Sendable {
        let length: AdaptyUIConfiguration.GridItem.Length
        let horizontalAlignment: AdaptyUIConfiguration.HorizontalAlignment
        let verticalAlignment: AdaptyUIConfiguration.VerticalAlignment
        let content: Schema.Element
    }
}

extension Schema.Localizer {
    func gridItem(_ from: Schema.GridItem) throws -> AdaptyUIConfiguration.GridItem {
        try .init(
            length: from.length,
            horizontalAlignment: from.horizontalAlignment,
            verticalAlignment: from.verticalAlignment,
            content: element(from.content)
        )
    }
}

extension Schema.GridItem: Decodable {
    enum CodingKeys: String, CodingKey {
        case fixed
        case weight
        case horizontalAlignment = "h_align"
        case verticalAlignment = "v_align"
        case content
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let length: AdaptyUIConfiguration.GridItem.Length =
            if let value = try container.decodeIfPresent(Int.self, forKey: .weight) {
                .weight(value)
            } else {
                try .fixed(container.decode(AdaptyUIConfiguration.Unit.self, forKey: .fixed))
            }

        try self.init(
            length: length,
            horizontalAlignment: container.decodeIfPresent(AdaptyUIConfiguration.HorizontalAlignment.self, forKey: .horizontalAlignment) ?? AdaptyUIConfiguration.GridItem.defaultHorizontalAlignment,
            verticalAlignment: container.decodeIfPresent(AdaptyUIConfiguration.VerticalAlignment.self, forKey: .verticalAlignment) ?? AdaptyUIConfiguration.GridItem.defaultVerticalAlignment,
            content: container.decode(Schema.Element.self, forKey: .content)
        )
    }
}
