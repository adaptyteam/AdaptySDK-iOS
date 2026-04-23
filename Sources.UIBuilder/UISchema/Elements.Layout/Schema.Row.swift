//
//  Schema.Row.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 28.03.2024
//

import Foundation

extension Schema {
    struct Row: Sendable {
        let width: AutoSizeMode
        let spacing: Double
        let items: [GridItem]
    }
}

extension Schema.Row: Schema.CompositeElement {
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
        _ resultStack: inout Schema.ConfigurationBuilder.ResultStack
    ) throws(Schema.Error) -> VC.Element {
        try .row(
            .init(
                width: width,
                spacing: spacing,
                items: builder.convertGridItems(items, resultStack.popLastElements(items.count))
            ),
            properties
        )
    }
}

extension Schema.Row: DecodableWithConfiguration {
    enum CodingKeys: String, CodingKey {
        case width
        case spacing
        case items
    }

    init(from decoder: Decoder, configuration: Schema.DecodingConfiguration) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let size: Schema.AutoSizeMode =
            if configuration.isLegacy {
                .legacy
            } else {
                try container.decodeIfPresent(Schema.AutoSizeMode.self, forKey: .width) ?? .default
            }

        try self.init(
            width: size,
            spacing: container.decodeIfPresent(Double.self, forKey: .spacing) ?? 0,
            items: container.decode([Schema.GridItem].self, forKey: .items, configuration: configuration)
        )
    }
}

