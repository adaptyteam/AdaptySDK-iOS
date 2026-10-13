//
//  Schema.DeckItem.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 21.08.2026.
//

import Foundation

extension Schema {
    struct DeckItem: Sendable {
        let width: Length
        let height: Length
        let horizontalAlignment: HorizontalAlignment
        let verticalAlignment: VerticalAlignment
        let content: Element
    }
}

extension Schema.DeckItem {
    static let `default` = (
        horizontalAlignment: VC.HorizontalAlignment.center,
        verticalAlignment: VC.VerticalAlignment.center
    )
}

extension Schema.ConfigurationBuilder {
    @inlinable
    func convertDeckItems(
        _ items: [Schema.DeckItem],
        _ elements: [VC.ElementIndex]
    ) -> [VC.DeckItem] {
        var deckItems = [VC.DeckItem]()
        deckItems.reserveCapacity(elements.count)
        for (index, item) in items.enumerated() {
            deckItems.append(.init(
                width: item.width,
                height: item.height,
                horizontalAlignment: item.horizontalAlignment,
                verticalAlignment: item.verticalAlignment,
                content: elements[index]
            ))
        }
        return deckItems
    }
}

extension Schema.DeckItem: DecodableWithConfiguration {
    static let typeForDeckItem = "deck_item"

    enum CodingKeys: String, CodingKey {
        case type
        case width
        case height
        case horizontalAlignment = "h_align"
        case verticalAlignment = "v_align"
        case content
    }

    init(from decoder: Decoder, configuration: Schema.InternalDecodingConfiguration) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let type = try container.decode(String.self, forKey: .type)

        guard type == Self.typeForDeckItem else {
            throw DecodingError.dataCorruptedError(
                forKey: .type,
                in: container,
                debugDescription: "Invalid DeckItem type: \(type)"
            )
        }

        try self.init(
            width: container.decodeIfPresent(Length.self, forKey: .width) ?? .content,
            height: container.decodeIfPresent(Length.self, forKey: .height) ?? .content,
            horizontalAlignment: container.decodeIfPresent(Schema.HorizontalAlignment.self, forKey: .horizontalAlignment) ?? Self.default.horizontalAlignment,
            verticalAlignment: container.decodeIfPresent(Schema.VerticalAlignment.self, forKey: .verticalAlignment) ?? Self.default.verticalAlignment,
            content: container.decode(Schema.Element.self, forKey: .content, configuration: configuration)
        )
    }
}
