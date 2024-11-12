//
//  VC.Reference.swift
//  AdqptyUI
//
//  Created by Aleksei Valiano on 06.06.2024
//
//

import Foundation

extension AdaptyViewSource.Localizer {
    func reference(_ id: String) throws -> AdaptyViewConfiguration.Element {
        guard !self.elementIds.contains(id) else {
            throw AdaptyViewLocalizerError.referenceCycle(id)
        }
        guard let value = source.referencedElemnts[id] else {
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
    var referencedElemnts: [(String, AdaptyViewSource.Element)] {
        [content, footer, overlay].compactMap { $0 }.flatMap { $0.referencedElemnts }
    }
}

private extension AdaptyViewSource.Button {
    var referencedElemnts: [(String, AdaptyViewSource.Element)] {
        [normalState, selectedState].compactMap { $0 }.flatMap { $0.referencedElemnts }
    }
}

private extension AdaptyViewSource.Element {
    var referencedElemnts: [(String, AdaptyViewSource.Element)] {
        switch self {
        case .reference: []
        case let .stack(value, properties):
            value.referencedElemnts + (properties?.referencedElemnts(self) ?? [])
        case let .text(value, properties):
            value.referencedElemnts + (properties?.referencedElemnts(self) ?? [])
        case let .image(value, properties):
            value.referencedElemnts + (properties?.referencedElemnts(self) ?? [])
        case let .video(value, properties):
            value.referencedElemnts + (properties?.referencedElemnts(self) ?? [])
        case let .button(value, properties):
            value.referencedElemnts + (properties?.referencedElemnts(self) ?? [])
        case let .box(value, properties):
            value.referencedElemnts + (properties?.referencedElemnts(self) ?? [])
        case let .row(value, properties):
            value.referencedElemnts + (properties?.referencedElemnts(self) ?? [])
        case let .column(value, properties):
            value.referencedElemnts + (properties?.referencedElemnts(self) ?? [])
        case let .section(value, properties):
            value.referencedElemnts + (properties?.referencedElemnts(self) ?? [])
        case let .toggle(value, properties):
            value.referencedElemnts + (properties?.referencedElemnts(self) ?? [])
        case let .timer(value, properties):
            value.referencedElemnts + (properties?.referencedElemnts(self) ?? [])
        case let .pager(value, properties):
            value.referencedElemnts + (properties?.referencedElemnts(self) ?? [])
        case let .unknown(_, properties):
            properties?.referencedElemnts(self) ?? []
        }
    }
}

private extension AdaptyViewSource.Element.Properties {
    func referencedElemnts(_ element: AdaptyViewSource.Element) -> [(String, AdaptyViewSource.Element)] {
        guard let elementId else { return [] }
        return [(elementId, element)]
    }
}

private extension AdaptyViewSource.Box {
    var referencedElemnts: [(String, AdaptyViewSource.Element)] {
        content?.referencedElemnts ?? []
    }
}

private extension AdaptyViewSource.Stack {
    var referencedElemnts: [(String, AdaptyViewSource.Element)] {
        items.flatMap { $0.referencedElemnts }
    }
}

private extension AdaptyViewSource.StackItem {
    var referencedElemnts: [(String, AdaptyViewSource.Element)] {
        switch self {
        case .space:
            []
        case let .element(value):
            value.referencedElemnts
        }
    }
}

private extension AdaptyViewSource.Section {
    var referencedElemnts: [(String, AdaptyViewSource.Element)] {
        content.flatMap { $0.referencedElemnts }
    }
}

private extension AdaptyViewSource.Pager {
    var referencedElemnts: [(String, AdaptyViewSource.Element)] {
        content.flatMap { $0.referencedElemnts }
    }
}

private extension AdaptyViewSource.Row {
    var referencedElemnts: [(String, AdaptyViewSource.Element)] {
        items.flatMap { $0.referencedElemnts }
    }
}

private extension AdaptyViewSource.Column {
    var referencedElemnts: [(String, AdaptyViewSource.Element)] {
        items.flatMap { $0.referencedElemnts }
    }
}

private extension AdaptyViewSource.GridItem {
    var referencedElemnts: [(String, AdaptyViewSource.Element)] {
        content.referencedElemnts
    }
}

private extension AdaptyViewSource.Text {
    var referencedElemnts: [(String, AdaptyViewSource.Element)] {
        []
    }
}

private extension AdaptyViewSource.Image {
    var referencedElemnts: [(String, AdaptyViewSource.Element)] {
        []
    }
}

private extension AdaptyViewSource.VideoPlayer {
    var referencedElemnts: [(String, AdaptyViewSource.Element)] {
        []
    }
}

private extension AdaptyViewSource.Toggle {
    var referencedElemnts: [(String, AdaptyViewSource.Element)] {
        []
    }
}

private extension AdaptyViewSource.Timer {
    var referencedElemnts: [(String, AdaptyViewSource.Element)] {
        []
    }
}
