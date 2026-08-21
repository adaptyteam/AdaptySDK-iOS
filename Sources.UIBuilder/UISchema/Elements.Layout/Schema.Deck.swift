//
//  Schema.Deck.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 21.08.2026.
//

import Foundation

extension Schema {
    struct Deck: Sendable {
        let width: AutoSizeMode
        let height: AutoSizeMode
        let items: [DeckItem]
    }
}

extension Schema.Deck: Schema.CompositeElement {
    @inlinable
    func planTasks(in taskStack: inout Schema.ConfigurationBuilder.TasksStack) {
        for item in items.reversed() {
            taskStack.append(.planElement(item.content))
        }
    }

    @inlinable
    func buildElement(
        _ builder: Schema.ConfigurationBuilder,
        _ properties: VC.Element.Properties?,
        _ elementIndices: inout [VC.ElementIndex]
    ) throws(Schema.Error) -> VC.Element {
        try .deck(
            .init(
                width: width,
                height: height,
                items: builder.convertDeckItems(items, elementIndices.pop(items.count))
            ),
            properties
        )
    }
}

extension Schema.Deck: DecodableWithConfiguration {
    enum CodingKeys: String, CodingKey {
        case width
        case height
        case items
    }

    init(from decoder: Decoder, configuration: Schema.InternalDecodingConfiguration) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let items = try container.decode([Schema.DeckItem].self, forKey: .items, configuration: configuration)

        guard !items.isEmpty else {
            throw DecodingError.dataCorruptedError(
                forKey: .items,
                in: container,
                debugDescription: "Deck must contain at least one item"
            )
        }

        try self.init(
            width: container.decodeIfPresent(Schema.AutoSizeMode.self, forKey: .width) ?? .default,
            height: container.decodeIfPresent(Schema.AutoSizeMode.self, forKey: .height) ?? .default,
            items: items
        )
    }
}
