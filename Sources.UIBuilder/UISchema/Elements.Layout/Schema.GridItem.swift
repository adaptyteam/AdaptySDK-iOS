//
//  Schema.GridItem.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 28.03.2024
//

import Foundation

extension Schema {
    struct GridItem: Sendable, Hashable {
        let length: Length
        let horizontalAlignment: HorizontalAlignment
        let verticalAlignment: VerticalAlignment
        let content: Element
    }
}

extension Schema.GridItem {
    static let `default` = VC.GridItem.default
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

extension Schema.GridItem: DecodableWithConfiguration {
    enum CodingKeys: String, CodingKey {
        case fixed
        case weight
        case horizontalAlignment = "h_align"
        case verticalAlignment = "v_align"
        case content
    }

    init(from decoder: Decoder, configuration: Schema.DecodingConfiguration) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let length: Schema.GridItem.Length =
            if let value = try container.decodeIfPresent(Int.self, forKey: .weight) {
                .weight(value)
            } else {
                try .fixed(container.decode(Schema.Unit.self, forKey: .fixed))
            }

        try self.init(
            length: length,
            horizontalAlignment: container.decodeIfPresent(Schema.HorizontalAlignment.self, forKey: .horizontalAlignment) ?? Self.default.horizontalAlignment,
            verticalAlignment: container.decodeIfPresent(Schema.VerticalAlignment.self, forKey: .verticalAlignment) ?? Self.default.verticalAlignment,
            content: container.decode(Schema.Element.self, forKey: .content, configuration: configuration)
        )
    }
}
