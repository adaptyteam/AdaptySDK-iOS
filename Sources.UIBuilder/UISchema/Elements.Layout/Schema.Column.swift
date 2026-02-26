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

extension Schema.ConfigurationBuilder {
    @inlinable
    func planColumn(
        _ value: Schema.Column,
        _ properties: VC.Element.Properties?,
        in taskStack: inout [Task]
    ) {
        taskStack.append(.buildColumn(value, properties))
        for item in value.items.reversed() {
            taskStack.append(.planElement(item.content))
        }
    }

    @inlinable
    func buildColumn(
        _ from: Schema.Column,
        _ elementStack: inout [VC.Element]
    ) throws(Schema.Error) -> VC.Column {
        let elements = try elementStack.popLastElements(from.items.count)
        return .init(
            spacing: from.spacing,
            items: convertGridItems(from.items, elements)
        )
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
