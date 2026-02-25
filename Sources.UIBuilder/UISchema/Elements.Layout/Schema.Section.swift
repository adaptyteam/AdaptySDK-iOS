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

extension Schema.Localizer {
    func planSection(
        _ value: Schema.Section,
        _ properties: Schema.Element.Properties?,
        in workStack: inout [WorkItem]
    ) throws {
        workStack.append(.buildSection(value, properties))
        for item in value.content.reversed() {
            workStack.append(.planElement(item))
        }
    }

    func buildSection(
        _ from: Schema.Section,
        _ properties: Schema.Element.Properties?,
        in resultStack: inout [VC.Element]
    ) {
        let count = from.content.count
        var elements = [VC.Element]()
        elements.reserveCapacity(count)
        for _ in 0 ..< count {
            elements.append(resultStack.removeLast())
        }
        elements.reverse()
        resultStack.append(.section(
            .init(
                index: from.index,
                content: elements
            ),
            properties?.value
        ))
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
