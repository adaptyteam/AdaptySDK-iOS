//
//  Schema.Row.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 28.03.2024
//

import Foundation

extension Schema {
    struct Row: Sendable, Hashable {
        let spacing: Double
        let items: [GridItem]
    }
}

extension Schema.Localizer {
    func planRow(
        _ value: Schema.Row,
        _ properties: Schema.Element.Properties?,
        in workStack: inout [WorkItem]
    ) throws {
        workStack.append(.buildRow(value, properties))
        for item in value.items.reversed() {
            workStack.append(.planElement(item.content))
        }
    }

    func buildRow(
        _ from: Schema.Row,
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
        resultStack.append(.row(
            .init(
                spacing: from.spacing,
                items: vcItems
            ),
            properties?.value
        ))
    }
}

extension Schema.Row: DecodableWithConfiguration {
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
