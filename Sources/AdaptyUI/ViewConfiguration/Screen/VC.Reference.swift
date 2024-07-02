//
//  VC.Reference.swift
//  AdqptyUI
//
//  Created by Aleksei Valiano on 06.06.2024
//
//

import Foundation

extension AdaptyUI.ViewConfiguration.Localizer {
    func reference(_ id: String) throws -> AdaptyUI.Element {
        guard !self.elementIds.contains(id) else {
            throw AdaptyUI.LocalizerError.referenceCycle(id)
        }
        guard let value = source.referencedElemnts[id] else {
            throw AdaptyUI.LocalizerError.unknownReference(id)
        }
        elementIds.insert(id)
        let result: AdaptyUI.Element
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

extension AdaptyUI.ViewConfiguration.Screen {
    var referencedElemnts: [(String, AdaptyUI.ViewConfiguration.Element)] {
        [content, footer, overlay].compactMap { $0 }.flatMap { $0.referencedElemnts }
    }
}

private extension AdaptyUI.ViewConfiguration.Button {
    var referencedElemnts: [(String, AdaptyUI.ViewConfiguration.Element)] {
        [normalState, selectedState].compactMap { $0 }.flatMap { $0.referencedElemnts }
    }
}

private extension AdaptyUI.ViewConfiguration.Element {
    var referencedElemnts: [(String, AdaptyUI.ViewConfiguration.Element)] {
        switch self {
        case .reference: []
        case let .stack(value, properties):
            value.referencedElemnts + (properties?.referencedElemnts(self) ?? [])
        case let .text(value, properties):
            value.referencedElemnts + (properties?.referencedElemnts(self) ?? [])
        case let .image(value, properties):
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

private extension AdaptyUI.ViewConfiguration.Element.Properties {
    func referencedElemnts(_ element: AdaptyUI.ViewConfiguration.Element) -> [(String, AdaptyUI.ViewConfiguration.Element)] {
        guard let elementId else { return [] }
        return [(elementId, element)]
    }
}

private extension AdaptyUI.ViewConfiguration.Box {
    var referencedElemnts: [(String, AdaptyUI.ViewConfiguration.Element)] {
        content?.referencedElemnts ?? []
    }
}

private extension AdaptyUI.ViewConfiguration.Stack {
    var referencedElemnts: [(String, AdaptyUI.ViewConfiguration.Element)] {
        items.flatMap { $0.referencedElemnts }
    }
}

private extension AdaptyUI.ViewConfiguration.StackItem {
    var referencedElemnts: [(String, AdaptyUI.ViewConfiguration.Element)] {
        switch self {
        case .space:
            []
        case let .element(value):
            value.referencedElemnts
        }
    }
}

private extension AdaptyUI.ViewConfiguration.Section {
    var referencedElemnts: [(String, AdaptyUI.ViewConfiguration.Element)] {
        content.flatMap { $0.referencedElemnts }
    }
}

private extension AdaptyUI.ViewConfiguration.Pager {
    var referencedElemnts: [(String, AdaptyUI.ViewConfiguration.Element)] {
        content.flatMap { $0.referencedElemnts }
    }
}

private extension AdaptyUI.ViewConfiguration.Row {
    var referencedElemnts: [(String, AdaptyUI.ViewConfiguration.Element)] {
        items.flatMap { $0.referencedElemnts }
    }
}

private extension AdaptyUI.ViewConfiguration.Column {
    var referencedElemnts: [(String, AdaptyUI.ViewConfiguration.Element)] {
        items.flatMap { $0.referencedElemnts }
    }
}

private extension AdaptyUI.ViewConfiguration.GridItem {
    var referencedElemnts: [(String, AdaptyUI.ViewConfiguration.Element)] {
        content.referencedElemnts
    }
}

private extension AdaptyUI.ViewConfiguration.Text {
    var referencedElemnts: [(String, AdaptyUI.ViewConfiguration.Element)] {
        []
    }
}

private extension AdaptyUI.ViewConfiguration.Image {
    var referencedElemnts: [(String, AdaptyUI.ViewConfiguration.Element)] {
        []
    }
}

private extension AdaptyUI.ViewConfiguration.Toggle {
    var referencedElemnts: [(String, AdaptyUI.ViewConfiguration.Element)] {
        []
    }
}

private extension AdaptyUI.ViewConfiguration.Timer {
    var referencedElemnts: [(String, AdaptyUI.ViewConfiguration.Element)] {
        []
    }
}
