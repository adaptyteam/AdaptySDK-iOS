//
//  Schema.LegacyTemplates.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 02.12.2025.
//

import Foundation

extension Schema {
    struct LegacyTemplates: Templates {
        let templates: [String: Element]
    }
}

extension Schema.LegacyTemplates {
    static func create(screens: [String: Schema.Screen]) throws -> Self {
        try .init(
            templates: [String: Schema.Element](
                screens.flatMap(\.value.legacyReferencedElements),
                uniquingKeysWith: { a, b in
                    throw Schema.Error.dublicateLegacyReference("elements: \(a), \(b)")
                }
            )
        )
    }
}

extension Schema.Localizer {
    func legacyReference(_ id: String) throws -> VC.Element {
        guard !self.templateIds.contains(id) else {
            throw Schema.Error.elementsTreeCycle(id)
        }
        guard let templates = source.templates as? Schema.LegacyTemplates else {
            throw Schema.Error.notFoundTemplate(id)
        }
        guard let instance = templates.templates[id] else {
            throw Schema.Error.notFoundTemplate(id)
        }
        templateIds.insert(id)
        let result: VC.Element
        do {
            result = try element(instance)
            templateIds.remove(id)
        } catch {
            templateIds.remove(id)
            throw error
        }
        return result
    }
}

private extension Schema.Screen {
    var legacyReferencedElements: [(String, Schema.Element)] {
        [content, footer, overlay].compactMap(\.self).flatMap(\.legacyReferencedElements)
    }
}

private extension Schema.Element {
    var legacyReferencedElements: [(String, Schema.Element)] {
        let (legacyElementId, childs): (String?, [Self]?) = switch self {
        case let .stack(stack, properties): (
                legacyElementId: properties?.legacyElementId,
                childs: stack.items
                    .compactMap {
                        switch $0 {
                        case .space:
                            nil
                        case let .element(element):
                            element
                        }
                    }
            )
        case let .button(button, properties): (
                legacyElementId: properties?.legacyElementId,
                childs: [button.normalState, button.selectedState].compactMap(\.self)
            )
        case let .box(box, properties): (
                legacyElementId: properties?.legacyElementId,
                childs: box.content.map { [$0] }
            )
        case let .row(row, properties): (
                legacyElementId: properties?.legacyElementId,
                childs: row.items.map(\.content)
            )
        case let .column(column, properties): (
                legacyElementId: properties?.legacyElementId,
                childs: column.items.map(\.content)
            )
        case let .section(section, properties): (
                legacyElementId: properties?.legacyElementId,
                childs: section.content
            )
        case let .pager(pager, properties): (
                legacyElementId: properties?.legacyElementId,
                childs: pager.content
            )
        case let .text(_, properties),
             let .image(_, properties),
             let .video(_, properties),
             let .toggle(_, properties),
             let .timer(_, properties),
             let .unknown(_, properties): (
                legacyElementId: properties?.legacyElementId,
                childs: nil
            )
        default: (
                legacyElementId: nil,
                childs: nil
            )
        }

        let legacyReferencedElements = childs?.flatMap(\.legacyReferencedElements) ?? []
        return if let legacyElementId {
            [(legacyElementId, self)] + legacyReferencedElements
        } else {
            legacyReferencedElements
        }
    }
}
