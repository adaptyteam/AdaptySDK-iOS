//
//  Schema.GridItem.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 28.03.2024
//

import Foundation

extension Schema {
    struct GridItem: Sendable {
        let length: VC.GridItem.Length
        let horizontalAlignment: VC.HorizontalAlignment
        let verticalAlignment: VC.VerticalAlignment
        let content: Schema.Element
    }
}

extension Schema.Localizer {
    func gridItem(_ from: Schema.GridItem) throws -> VC.GridItem {
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
        let length: VC.GridItem.Length =
            if let value = try container.decodeIfPresent(Int.self, forKey: .weight) {
                .weight(value)
            } else {
                try .fixed(container.decode(VC.Unit.self, forKey: .fixed))
            }

        try self.init(
            length: length,
            horizontalAlignment: container.decodeIfPresent(VC.HorizontalAlignment.self, forKey: .horizontalAlignment) ?? VC.GridItem.defaultHorizontalAlignment,
            verticalAlignment: container.decodeIfPresent(VC.VerticalAlignment.self, forKey: .verticalAlignment) ?? VC.GridItem.defaultVerticalAlignment,
            content: container.decode(Schema.Element.self, forKey: .content)
        )
    }
}
