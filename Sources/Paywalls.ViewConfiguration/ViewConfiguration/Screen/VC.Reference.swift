//
//  VC.Reference.swift
//  AdqptyUI
//
//  Created by Aleksei Valiano on 06.06.2024
//
//

import Foundation

extension AdaptyUICore.ViewConfiguration.Localizer {
    func reference(_ id: String) throws -> AdaptyUICore.Element {
        guard !self.elementIds.contains(id) else {
            throw AdaptyUICore.LocalizerError.referenceCycle(id)
        }
        guard let value = source.referencedElemnts[id] else {
            throw AdaptyUICore.LocalizerError.unknownReference(id)
        }
        elementIds.insert(id)
        let result: AdaptyUICore.Element
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

extension AdaptyUICore.ViewConfiguration.Screen {
    var referencedElemnts: [(String, AdaptyUICore.ViewConfiguration.Element)] {
        [content, footer, overlay].compactMap { $0 }.flatMap { $0.referencedElemnts }
    }
}

private extension AdaptyUICore.ViewConfiguration.Button {
    var referencedElemnts: [(String, AdaptyUICore.ViewConfiguration.Element)] {
        [normalState, selectedState].compactMap { $0 }.flatMap { $0.referencedElemnts }
    }
}

private extension AdaptyUICore.ViewConfiguration.Element {
    var referencedElemnts: [(String, AdaptyUICore.ViewConfiguration.Element)] {
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

private extension AdaptyUICore.ViewConfiguration.Element.Properties {
    func referencedElemnts(_ element: AdaptyUICore.ViewConfiguration.Element) -> [(String, AdaptyUICore.ViewConfiguration.Element)] {
        guard let elementId else { return [] }
        return [(elementId, element)]
    }
}

private extension AdaptyUICore.ViewConfiguration.Box {
    var referencedElemnts: [(String, AdaptyUICore.ViewConfiguration.Element)] {
        content?.referencedElemnts ?? []
    }
}

private extension AdaptyUICore.ViewConfiguration.Stack {
    var referencedElemnts: [(String, AdaptyUICore.ViewConfiguration.Element)] {
        items.flatMap { $0.referencedElemnts }
    }
}

private extension AdaptyUICore.ViewConfiguration.StackItem {
    var referencedElemnts: [(String, AdaptyUICore.ViewConfiguration.Element)] {
        switch self {
        case .space:
            []
        case let .element(value):
            value.referencedElemnts
        }
    }
}

private extension AdaptyUICore.ViewConfiguration.Section {
    var referencedElemnts: [(String, AdaptyUICore.ViewConfiguration.Element)] {
        content.flatMap { $0.referencedElemnts }
    }
}

private extension AdaptyUICore.ViewConfiguration.Pager {
    var referencedElemnts: [(String, AdaptyUICore.ViewConfiguration.Element)] {
        content.flatMap { $0.referencedElemnts }
    }
}

private extension AdaptyUICore.ViewConfiguration.Row {
    var referencedElemnts: [(String, AdaptyUICore.ViewConfiguration.Element)] {
        items.flatMap { $0.referencedElemnts }
    }
}

private extension AdaptyUICore.ViewConfiguration.Column {
    var referencedElemnts: [(String, AdaptyUICore.ViewConfiguration.Element)] {
        items.flatMap { $0.referencedElemnts }
    }
}

private extension AdaptyUICore.ViewConfiguration.GridItem {
    var referencedElemnts: [(String, AdaptyUICore.ViewConfiguration.Element)] {
        content.referencedElemnts
    }
}

private extension AdaptyUICore.ViewConfiguration.Text {
    var referencedElemnts: [(String, AdaptyUICore.ViewConfiguration.Element)] {
        []
    }
}

private extension AdaptyUICore.ViewConfiguration.Image {
    var referencedElemnts: [(String, AdaptyUICore.ViewConfiguration.Element)] {
        []
    }
}

private extension AdaptyUICore.ViewConfiguration.VideoPlayer {
    var referencedElemnts: [(String, AdaptyUICore.ViewConfiguration.Element)] {
        []
    }
}

private extension AdaptyUICore.ViewConfiguration.Toggle {
    var referencedElemnts: [(String, AdaptyUICore.ViewConfiguration.Element)] {
        []
    }
}

private extension AdaptyUICore.ViewConfiguration.Timer {
    var referencedElemnts: [(String, AdaptyUICore.ViewConfiguration.Element)] {
        []
    }
}
