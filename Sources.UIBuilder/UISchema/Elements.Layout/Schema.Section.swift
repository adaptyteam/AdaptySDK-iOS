//
//  Schema.Section.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 28.03.2024
//

import Foundation

extension Schema {
    struct Section: Sendable {
        let index: Variable
        let content: [Schema.Element]
        let transition: Transition?
    }
}

extension Schema.Section: Schema.CompositeElement {
    @inlinable
    func planTasks(in taskStack: inout Schema.ConfigurationBuilder.TasksStack) {
        for item in content.reversed() {
            taskStack.append(.planElement(item))
        }
    }

    @inlinable
    func buildElement(
        _: Schema.ConfigurationBuilder,
        _ properties: VC.Element.Properties?,
        _ elementIndices: inout [VC.ElementIndex]
    ) throws(Schema.Error) -> VC.Element {
        try .section(
            .init(
                index: index,
                content: elementIndices.pop(content.count),
                transition: transition
            ),
            properties
        )
    }
}

extension Schema.Section: DecodableWithConfiguration {
    enum CodingKeys: String, CodingKey {
        case legacySectionId = "id"
        case index
        case content
        case duration
        case interpolator
    }

    init(from decoder: Decoder, configuration: Schema.DecodingConfiguration) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        guard configuration.isLegacy else {
            let transition: Schema.Transition? =
                if container.exist(.duration) {
                    try .init(
                        startDelay: 0,
                        duration: container.decode(Double.self, forKey: .duration) / 1000.0,
                        interpolator: container.decodeIfPresent(VC.Animation.Interpolator.self, forKey: .interpolator) ?? .default
                    )
                } else {
                    nil
                }

            try self.init(
                index: container.decode(Schema.Variable.self, forKey: .index),
                content: container.decode([Schema.Element].self, forKey: .content, configuration: configuration),
                transition: transition
            )
            return
        }

        let sectionId = try container.decode(String.self, forKey: .legacySectionId)
        let index = try container.decodeIfPresent(Int32.self, forKey: .index) ?? 0
        configuration.collector.legacySectionsState[sectionId] = index

        try self.init(
            index: .init(
                path: ["Legacy", "sections", sectionId],
                setter: nil,
                scope: .global,
                converter: nil
            ),
            content: container.decode([Schema.Element].self, forKey: .content, configuration: configuration),
            transition: nil
        )
    }
}

