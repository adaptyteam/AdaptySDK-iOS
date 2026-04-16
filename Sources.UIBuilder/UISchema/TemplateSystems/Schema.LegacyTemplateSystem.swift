//
//  Schema.LegacyTemplateSystem.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 02.12.2025.
//

import Foundation

extension AdaptyUISchema {
    struct LegacyTemplateSystem: TemplateSystem {
        let templates: [String: Element]
    }
}

extension AdaptyUISchema.LegacyTemplateSystem {
    static func create(
        screens: [String: Schema.Screen],
        navigators: [Schema.NavigatorIdentifier: Schema.Navigator]
    ) throws -> Self {
        try .init(
            templates: [String: Schema.Element](
                screens.flatMap(\.value.legacyReferencedElements) + navigators.flatMap(\.value.legacyReferencedElements),
                uniquingKeysWith: { a, b in
                    throw Schema.Error.dublicateLegacyReference("elements: \(a), \(b)")
                }
            )
        )
    }
}

extension Schema.ConfigurationBuilder {
    @inlinable
    func planLegacyReference(
        _ id: String,
        in taskStack: inout TasksStack
    ) throws(Schema.Error) {
        guard !templateIds.contains(id) else {
            throw Schema.Error.elementsTreeCycle(id)
        }
        guard let templates = source.templates as? Schema.LegacyTemplateSystem else {
            throw Schema.Error.notFoundTemplate(id)
        }
        guard let instance = templates.templates[id] else {
            throw Schema.Error.notFoundTemplate(id)
        }
        templateIds.insert(id)
        taskStack.append(.leaveTemplate(id))
        taskStack.append(.planElement(instance))
    }
}

private extension Schema.Navigator {
    var legacyReferencedElements: [(String, Schema.Element)] {
        [content].compactMap(\.self).flatMap(\.legacyReferencedElements)
    }
}

private extension Schema.Screen {
    var legacyReferencedElements: [(String, Schema.Element)] {
        [content, footer].compactMap(\.self).flatMap(\.legacyReferencedElements)
    }
}

private extension Schema.Element {
    var legacyReferencedElements: [(String, Schema.Element)] {
        var childs: [Self]?
        if case let .compositeElement(element) = node {
            if let stack = element as? Schema.Stack {
                childs = stack.items
                    .compactMap {
                        switch $0 {
                        case .space:
                            nil
                        case let .element(element):
                            element
                        }
                    }
            } else if let button = element as? Schema.Button {
                childs = [button.content, button.legacySelectedContent].compactMap(\.self)
            } else if let box = element as? Schema.Box {
                childs = box.content.map { [$0] }
            } else if let row = element as? Schema.Row {
                childs = row.items.map(\.content)
            } else if let column = element as? Schema.Column {
                childs = column.items.map(\.content)
            } else if let section = element as? Schema.Section {
                childs = section.content
            } else if let pager = element as? Schema.Pager {
                childs = pager.content
            }
        }

        let legacyReferencedElements = childs?.flatMap(\.legacyReferencedElements) ?? []

        return if let legacyElementId = properties?.legacyElementId {
            [(legacyElementId, self)] + legacyReferencedElements
        } else {
            legacyReferencedElements
        }
    }
}
