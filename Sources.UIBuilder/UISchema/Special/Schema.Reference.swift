//
//  Schema.Reference.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 06.06.2024
//

import Foundation

extension Schema.Localizer {
    func reference(_ id: String) throws -> VC.Element {
        guard !self.elementIds.contains(id) else {
            throw Schema.LocalizerError.referenceCycle(id)
        }
        guard let value = source.referencedElements[id] else {
            throw Schema.LocalizerError.unknownReference(id)
        }
        elementIds.insert(id)
        let result: VC.Element
        do {
            result = try element(value)
            elementIds.remove(id)
        } catch {
            elementIds.remove(id)
            throw error
        }
        return result
    }
}

extension Schema.Screen {
    var referencedElements: [(String, Schema.Element)] {
        [content, footer, overlay].compactMap(\.self).flatMap(\.referencedElements)
    }
}

private extension Schema.Element {
    var referencedElements: [(String, Schema.Element)] {
        let (elementId, childs): (String?, [Self]?) = switch self {
        case let .stack(stack, properties): (
                elementId: properties?.elementId,
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
                elementId: properties?.elementId,
                childs: [button.normalState, button.selectedState].compactMap(\.self)
            )
        case let .box(box, properties): (
                elementId: properties?.elementId,
                childs: box.content.map { [$0] }
            )
        case let .row(row, properties): (
                elementId: properties?.elementId,
                childs: row.items.map(\.content)
            )
        case let .column(column, properties): (
                elementId: properties?.elementId,
                childs: column.items.map(\.content)
            )
        case let .section(section, properties): (
                elementId: properties?.elementId,
                childs: section.content
            )
        case let .pager(pager, properties): (
                elementId: properties?.elementId,
                childs: pager.content
            )
        case let .text(_, properties),
             let .image(_, properties),
             let .video(_, properties),
             let .toggle(_, properties),
             let .timer(_, properties),
             let .unknown(_, properties): (
                elementId: properties?.elementId,
                childs: nil
            )
        default: (
                elementId: nil,
                childs: nil
            )
        }

        let referencedElements = childs?.flatMap(\.referencedElements) ?? []
        return if let elementId {
            [(elementId, self)] + referencedElements
        } else {
            referencedElements
        }
    }
}
