//
//  Schema.Column.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 28.03.2024
//

import Foundation

extension Schema {
    struct Column: Sendable {
        let height: AutoSizeMode
        let spacing: Double
        let items: [GridItem]
    }
}

extension Schema.Column: Schema.CompositeElement {
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
        try .column(
            .init(
                height: height,
                spacing: spacing,
                items: builder.convertGridItems(items, resultStack.popLastElements(items.count))
            ),
            properties
        )
    }
}

extension Schema.Column: DecodableWithConfiguration {
    enum CodingKeys: String, CodingKey {
        case height
        case spacing
        case items
    }

    init(from decoder: Decoder, configuration: Schema.DecodingConfiguration) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let size: Schema.AutoSizeMode =
            if configuration.isLegacy {
                .legacy
            } else {
                try container.decodeIfPresent(Schema.AutoSizeMode.self, forKey: .height) ?? .default
            }

        try self.init(
            height: size,
            spacing: container.decodeIfPresent(Double.self, forKey: .spacing) ?? 0,
            items: container.decode([Schema.GridItem].self, forKey: .items, configuration: configuration)
        )
    }
}

