//
//  Schema.Section.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 28.03.2024
//

import Foundation

extension Schema {
    struct Section: Sendable, Hashable {
        let index: Variable
        let content: [Schema.Element]
    }
}

extension Schema.ConfigurationBuilder {
    @inlinable
    func planSection(
        _ value: Schema.Section,
        _ properties: VC.Element.Properties?,
        in taskStack: inout [Task]
    ) {
        taskStack.append(.buildSection(value, properties))
        for item in value.content.reversed() {
            taskStack.append(.planElement(item))
        }
    }

    @inlinable
    func buildSection(
        _ from: Schema.Section,
        _ elementStack: inout [VC.Element]
    ) throws(Schema.Error) -> VC.Section {
        let content = try elementStack.popLastElements(from.content.count)
        return .init(
            index: from.index,
            content: content
        )
    }
}

extension Schema.Section: DecodableWithConfiguration {
    enum CodingKeys: String, CodingKey {
        case legacySectionId = "id"
        case index
        case content
    }

    init(from decoder: Decoder, configuration: Schema.DecodingConfiguration) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        guard configuration.isLegacy else {
            try self.init(
                index: container.decode(Schema.Variable.self, forKey: .index),
                content: container.decode([Schema.Element].self, forKey: .content, configuration: configuration)
            )
            return
        }

        let sectionId = try container.decode(String.self, forKey: .legacySectionId)
        let index = try container.decodeIfPresent(Int32.self, forKey: .index) ?? 0
        configuration.collector.legacySectionsState[sectionId] = index

        try self.init(
            index: .init(
                path: ["Legacy", "sections", sectionId, "index"],
                setter: nil,
                scope: .global,
                converter: nil
            ),
            content: container.decode([Schema.Element].self, forKey: .content, configuration: configuration)
        )
    }
}
