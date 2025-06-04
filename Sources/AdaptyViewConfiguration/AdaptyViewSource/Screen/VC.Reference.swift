//
//  VC.Reference.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 06.06.2024
//

import Foundation

extension AdaptyViewSource.Localizer {
    func reference(_ id: String) throws -> AdaptyViewConfiguration.Element {
        guard !self.elementIds.contains(id) else {
            throw AdaptyViewLocalizerError.referenceCycle(id)
        }
        guard let value = source.referencedElements[id] else {
            throw AdaptyViewLocalizerError.unknownReference(id)
        }
        elementIds.insert(id)
        let result: AdaptyViewConfiguration.Element
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

extension AdaptyViewSource.Screen {
    var referencedElements: [(String, AdaptyViewSource.Element)] {
        [content, footer, overlay].compactMap { $0 }.flatMap { $0.referencedElements }
    }
}

private extension AdaptyViewSource.Button {
    var referencedElements: [(String, AdaptyViewSource.Element)] {
        [normalState, selectedState].compactMap { $0 }.flatMap { $0.referencedElements }
    }
}

private extension AdaptyViewSource.Element {
    var referencedElements: [(String, AdaptyViewSource.Element)] {
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

private extension AdaptyViewSource.Element.Properties {
    func referencedElements(_ element: AdaptyViewSource.Element) -> [(String, AdaptyViewSource.Element)] {
        guard let elementId else { return [] }
        return [(elementId, element)]
    }
}

private extension AdaptyViewSource.Box {
    var referencedElements: [(String, AdaptyViewSource.Element)] {
        content?.referencedElements ?? []
    }
}

private extension AdaptyViewSource.Stack {
    var referencedElements: [(String, AdaptyViewSource.Element)] {
        items.flatMap { $0.referencedElements }
    }
}

private extension AdaptyViewSource.StackItem {
    var referencedElements: [(String, AdaptyViewSource.Element)] {
        switch self {
        case .space:
            []
        case let .element(value):
            value.referencedElements
        }
    }
}

private extension AdaptyViewSource.Section {
    var referencedElements: [(String, AdaptyViewSource.Element)] {
        content.flatMap { $0.referencedElements }
    }
}

private extension AdaptyViewSource.Pager {
    var referencedElements: [(String, AdaptyViewSource.Element)] {
        content.flatMap { $0.referencedElements }
    }
}

private extension AdaptyViewSource.Row {
    var referencedElements: [(String, AdaptyViewSource.Element)] {
        items.flatMap { $0.referencedElements }
    }
}

private extension AdaptyViewSource.Column {
    var referencedElements: [(String, AdaptyViewSource.Element)] {
        items.flatMap { $0.referencedElements }
    }
}

private extension AdaptyViewSource.GridItem {
    var referencedElements: [(String, AdaptyViewSource.Element)] {
        content.referencedElements
    }
}

private extension AdaptyViewSource.Text {
    var referencedElements: [(String, AdaptyViewSource.Element)] {
        []
    }
}

private extension AdaptyViewSource.Image {
    var referencedElements: [(String, AdaptyViewSource.Element)] {
        []
    }
}

private extension AdaptyViewSource.VideoPlayer {
    var referencedElements: [(String, AdaptyViewSource.Element)] {
        []
    }
}

private extension AdaptyViewSource.Toggle {
    var referencedElements: [(String, AdaptyViewSource.Element)] {
        []
    }
}

private extension AdaptyViewSource.Timer {
    var referencedElements: [(String, AdaptyViewSource.Element)] {
        []
    }
}
