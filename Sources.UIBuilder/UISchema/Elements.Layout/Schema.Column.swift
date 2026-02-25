//
//  Schema.Column.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 28.03.2024
//

import Foundation

extension Schema {
    struct Column: Sendable, Hashable {
        let spacing: Double
        let items: [GridItem]
    }
}

extension Schema.Localizer {
    func planColumn(
        _ value: Schema.Column,
        _ properties: Schema.Element.Properties?,
        in workStack: inout [WorkItem]
    ) throws {
        workStack.append(.buildColumn(value, properties))
        for item in value.items.reversed() {
            workStack.append(.planElement(item.content))
        }
    }

    func buildColumn(
        _ from: Schema.Column,
        _ properties: Schema.Element.Properties?,
        in resultStack: inout [VC.Element]
    ) {
        let count = from.items.count
        var elements = [VC.Element]()
        elements.reserveCapacity(count)
        for _ in 0 ..< count {
            elements.append(resultStack.removeLast())
        }
        elements.reverse()

        var vcItems = [VC.GridItem]()
        vcItems.reserveCapacity(count)
        for (i, item) in from.items.enumerated() {
            vcItems.append(.init(
                length: item.length,
                horizontalAlignment: item.horizontalAlignment,
                verticalAlignment: item.verticalAlignment,
                content: elements[i]
            ))
        }
        resultStack.append(.column(
            .init(
                spacing: from.spacing,
                items: vcItems
            ),
            properties?.value
        ))
    }
}

extension Schema.Column: DecodableWithConfiguration {
    enum CodingKeys: String, CodingKey {
        case spacing
        case items
    }

    init(from decoder: Decoder, configuration: Schema.DecodingConfiguration) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            spacing: container.decodeIfPresent(Double.self, forKey: .spacing) ?? 0,
            items: container.decode([Schema.GridItem].self, forKey: .items, configuration: configuration)
        )
    }
}
