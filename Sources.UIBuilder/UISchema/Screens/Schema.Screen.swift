//
//  Schema.Screen.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 28.03.2024
//

import Foundation

extension Schema {
    struct Screen: Sendable, Hashable {
        let id: String
        let layoutBehaviour: LayoutBehaviour
        let cover: Box?
        let content: Element
        let footer: Element?
        let background: [Element.Overlay]?
        let overlay: [Element.Overlay]?
        let screenActions: ScreenActions
    }
}

extension Schema.ConfigurationBuilder {
    @inlinable
    func convertScreen(_ from: Schema.Screen) throws(Schema.Error) -> VC.Screen {
        var taskStack: TasksStack = []
        if let boxContent = from.cover?.content {
            taskStack.append(.planElement(boxContent))
        }
        taskStack.append(.planElement(from.content))
        if let footer = from.footer {
            taskStack.append(.planElement(footer))
        }

        if let array = from.background {
            for overlay in array.reversed() {
                taskStack.append(.planElement(overlay.content))
            }
        }

        if let array = from.overlay {
            for overlay in array.reversed() {
                taskStack.append(.planElement(overlay.content))
            }
        }
        var resultStack = try startTasks(&taskStack)
        return try buildScreen(from, &resultStack)
    }

    private func buildScreen(
        _ from: Schema.Screen,
        _ resultStack: inout ResultStack
    ) throws(Schema.Error) -> VC.Screen {
        var cover: VC.Box?
        if let box = from.cover {
            cover = try buildBox(box, &resultStack)
        }
        let content = try resultStack.popLastElement()
        let footer = try resultStack.popLastElement(from.footer != nil)

        var background: [VC.Element.Overlay]?
        if let from = from.background, from.isNotEmpty {
            background = try convertElementOverlays(
                from,
                resultStack.popLastElements(from.count)
            )
            if background.isEmpty {
                background = nil
            }
        }

        var overlay: [VC.Element.Overlay]?
        if let from = from.overlay, from.isNotEmpty {
            overlay = try convertElementOverlays(
                from,
                resultStack.popLastElements(from.count)
            )
            if overlay.isEmpty {
                overlay = nil
            }
        }

        return .init(
            id: from.id,
            layoutBehaviour: from.layoutBehaviour,
            cover: cover,
            content: content,
            footer: footer,
            background: background,
            overlay: overlay,
            screenActions: from.screenActions
        )
    }
}

extension Schema.Screen: DecodableWithConfiguration {
    enum CodingKeys: String, CodingKey {
        case layoutBehaviour = "layout_behaviour"
        case cover
        case content
        case footer
        case background
        case overlay
    }

    init(from decoder: any Decoder, configuration: Schema.DecodingConfiguration) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let layoutBehaviour =
            if let value = configuration.screenLayoutBehaviourFromLegacy {
                value
            } else {
                try container.decodeIfPresent(LayoutBehaviour.self, forKey: .layoutBehaviour) ?? .default
            }

        let screenId =
            if let value = configuration.insideScreenId {
                value
            } else {
                throw DecodingError.dataCorrupted(.init(codingPath: decoder.codingPath, debugDescription: "Unknown screen id"))
            }

        let background: [Schema.Element.Overlay]? =
            if configuration.isLegacy {
                nil
            } else {
                try container.decodeIfPresent([Schema.Element.Overlay].self, forKey: .background, configuration: configuration)
            }

        let overlay: [Schema.Element.Overlay]? =
            if configuration.isLegacy {
                if let one = try container.decodeIfPresent(Schema.Element.self, forKey: .overlay, configuration: configuration) {
                    [Schema.Element.Overlay(
                        horizontalAlignment: Schema.Element.Overlay.default.horizontalAlignment,
                        verticalAlignment: Schema.Element.Overlay.default.verticalAlignment,
                        content: one
                    )]
                } else {
                    nil
                }
            } else {
                try container.decodeIfPresent([Schema.Element.Overlay].self, forKey: .overlay, configuration: configuration)
            }

        try self.init(
            id: screenId,
            layoutBehaviour: layoutBehaviour,
            cover: layoutBehaviour == .hero ? container.decodeIfPresent(Schema.Box.self, forKey: .cover, configuration: configuration) : nil,
            content: container.decode(Schema.Element.self, forKey: .content, configuration: configuration),
            footer: layoutBehaviour != .default ? container.decodeIfPresent(Schema.Element.self, forKey: .footer, configuration: configuration) : nil,
            background: background,
            overlay: overlay,
            screenActions: Schema.ScreenActions(from: decoder)
        )
    }
}
