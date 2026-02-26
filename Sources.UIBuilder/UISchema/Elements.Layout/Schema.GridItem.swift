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
    static let `default` = (
        horizontalAlignment: VC.HorizontalAlignment.center,
        verticalAlignment: VC.VerticalAlignment.center
    )
}

extension Schema.ConfigurationBuilder {
    @inlinable
    func convertGridItems(
        _ items: [Schema.GridItem],
        _ elements: [VC.Element]
    ) -> [VC.GridItem] {
        var gridItems = [VC.GridItem]()
        gridItems.reserveCapacity(elements.count)
        for (i, item) in items.enumerated() {
            gridItems.append(.init(
                length: item.length,
                horizontalAlignment: item.horizontalAlignment,
                verticalAlignment: item.verticalAlignment,
                content: elements[i]
            ))
        }
        return gridItems
    }
}

extension Schema.GridItem: DecodableWithConfiguration {
    static let typeForGridItem = "grid_item"
    enum CodingKeys: String, CodingKey {
        case type
        case fixed
        case weight
        case horizontalAlignment = "h_align"
        case verticalAlignment = "v_align"
        case content
    }

    init(from decoder: Decoder, configuration: Schema.DecodingConfiguration) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if !configuration.isLegacy {
            let type = try container.decode(String.self, forKey: .type)

            guard type == Self.typeForGridItem else {
                throw DecodingError.dataCorrupted(.init(codingPath: decoder.codingPath, debugDescription: "worng type for GridItem: \(type)"))
            }
        }

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
