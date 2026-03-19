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

extension Schema.ConfigurationBuilder {
    @inlinable
    func planRow(
        _ from: Schema.Row,
        in taskStack: inout TasksStack
    ) {
        for item in from.items.reversed() {
            taskStack.append(.planElement(item.content))
        }
    }

    @inlinable
    func buildRow(
        _ from: Schema.Row,
        _ resultStack: inout ResultStack
    ) throws(Schema.Error) -> VC.Row {
        let elements = try resultStack.popLastElements(from.items.count)
        return .init(
            spacing: from.spacing,
            items: convertGridItems(from.items, elements)
        )
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
