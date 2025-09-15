//
//  Schema.Reference.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 06.06.2024
//

import Foundation

extension Schema.Localizer {
    func reference(_ id: String) throws -> AdaptyUIConfiguration.Element {
        guard !self.elementIds.contains(id) else {
            throw Schema.LocalizerError.referenceCycle(id)
        }
        guard let value = source.referencedElements[id] else {
            throw Schema.LocalizerError.unknownReference(id)
        }
        elementIds.insert(id)
        let result: AdaptyUIConfiguration.Element
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
        [content, footer, overlay].compactMap { $0 }.flatMap { $0.referencedElements }
    }
}

private extension Schema.Button {
    var referencedElements: [(String, Schema.Element)] {
        [normalState, selectedState].compactMap { $0 }.flatMap { $0.referencedElements }
    }
}

private extension Schema.Element {
    var referencedElements: [(String, Schema.Element)] {
        switch self {
        case .reference: []
        case let .stack(value, properties):
            value.referencedElements + (properties?.referencedElements(self) ?? [])
        case let .text(value, properties):
            value.referencedElements + (properties?.referencedElements(self) ?? [])
        case let .image(value, properties):
            value.referencedElements + (properties?.referencedElements(self) ?? [])
        case let .video(value, properties):
            value.referencedElements + (properties?.referencedElements(self) ?? [])
        case let .button(value, properties):
            value.referencedElements + (properties?.referencedElements(self) ?? [])
        case let .box(value, properties):
            value.referencedElements + (properties?.referencedElements(self) ?? [])
        case let .row(value, properties):
            value.referencedElements + (properties?.referencedElements(self) ?? [])
        case let .column(value, properties):
            value.referencedElements + (properties?.referencedElements(self) ?? [])
        case let .section(value, properties):
            value.referencedElements + (properties?.referencedElements(self) ?? [])
        case let .toggle(value, properties):
            value.referencedElements + (properties?.referencedElements(self) ?? [])
        case let .timer(value, properties):
            value.referencedElements + (properties?.referencedElements(self) ?? [])
        case let .pager(value, properties):
            value.referencedElements + (properties?.referencedElements(self) ?? [])
        case let .unknown(_, properties):
            properties?.referencedElements(self) ?? []
        }
    }
}

private extension Schema.Element.Properties {
    func referencedElements(_ element: Schema.Element) -> [(String, Schema.Element)] {
        guard let elementId else { return [] }
        return [(elementId, element)]
    }
}

private extension Schema.Box {
    var referencedElements: [(String, Schema.Element)] {
        content?.referencedElements ?? []
    }
}

private extension Schema.Stack {
    var referencedElements: [(String, Schema.Element)] {
        items.flatMap { $0.referencedElements }
    }
}

private extension Schema.StackItem {
    var referencedElements: [(String, Schema.Element)] {
        switch self {
        case .space:
            []
        case let .element(value):
            value.referencedElements
        }
    }
}

private extension Schema.Section {
    var referencedElements: [(String, Schema.Element)] {
        content.flatMap { $0.referencedElements }
    }
}

private extension Schema.Pager {
    var referencedElements: [(String, Schema.Element)] {
        content.flatMap { $0.referencedElements }
    }
}

private extension Schema.Row {
    var referencedElements: [(String, Schema.Element)] {
        items.flatMap { $0.referencedElements }
    }
}

private extension Schema.Column {
    var referencedElements: [(String, Schema.Element)] {
        items.flatMap { $0.referencedElements }
    }
}

private extension Schema.GridItem {
    var referencedElements: [(String, Schema.Element)] {
        content.referencedElements
    }
}

private extension Schema.Text {
    var referencedElements: [(String, Schema.Element)] {
        []
    }
}

private extension Schema.Image {
    var referencedElements: [(String, Schema.Element)] {
        []
    }
}

private extension Schema.VideoPlayer {
    var referencedElements: [(String, Schema.Element)] {
        []
    }
}

private extension Schema.Toggle {
    var referencedElements: [(String, Schema.Element)] {
        []
    }
}

private extension Schema.Timer {
    var referencedElements: [(String, Schema.Element)] {
        []
    }
}
