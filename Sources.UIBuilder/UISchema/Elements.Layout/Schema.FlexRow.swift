//
//  Schema.FlexRow.swift
//  AdaptyUIBuilder
//
//  Created by Aleksey Goncharov on 16.04.2026
//

import Foundation

extension Schema {
    struct FlexRow: Sendable {
        let spacing: Double
        let items: [GridItem]
    }
}

extension Schema.FlexRow: Schema.CompositeElement {
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
        try .flexRow(
            .init(
                spacing: spacing,
                items: builder.convertGridItems(items, resultStack.popLastElements(items.count))
            ),
            properties
        )
    }
}

extension Schema.FlexRow: DecodableWithConfiguration {
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
