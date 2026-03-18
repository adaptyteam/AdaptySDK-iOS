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
        let overlay: [Element]?
        let screenActions: ScreenActions
    }
}

extension Schema.ConfigurationBuilder {
    @inlinable
    func convertScreen(_ from: Schema.Screen) throws(Schema.Error) -> VC.Screen {
        var taskStack: [Task] = []
        if let boxContent = from.cover?.content {
            taskStack.append(.planElement(boxContent))
        }
        taskStack.append(.planElement(from.content))
        if let footer = from.footer {
            taskStack.append(.planElement(footer))
        }
        if let overlay = from.overlay {
            for el in overlay.reversed() {
                taskStack.append(.planElement(el))
            }
        }
        var elementStack = try startTasks(&taskStack)
        return try buildScreen(from, &elementStack)
    }

    private func buildScreen(
        _ from: Schema.Screen,
        _ elementStack: inout [VC.Element]
    ) throws(Schema.Error) -> VC.Screen {
        var cover: VC.Box?
        if let box = from.cover {
            cover = try buildBox(box, &elementStack)
        }
        let content = try elementStack.popLastElement()
        let footer = try elementStack.popLastElement(from.footer != nil)
        let overlay = try elementStack.popLastElements(from.overlay?.count ?? 0)
        return .init(
            id: from.id,
            layoutBehaviour: from.layoutBehaviour,
            cover: cover,
            content: content,
            footer: footer,
            overlay: overlay.isEmpty ? nil : overlay,
            screenActions: from.screenActions
        )
    }
}

extension Schema.Screen: Encodable, DecodableWithConfiguration {
    enum CodingKeys: String, CodingKey {
        case layoutBehaviour = "layout_behaviour"
        case cover
        case content
        case footer
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

        let overlay: [Schema.Element]? =
            if !container.contains(.overlay) {
                nil
            } else if let one = try? container.decode(Schema.Element.self, forKey: .overlay, configuration: configuration) {
                [one]
            } else {
                try? container.decode([Schema.Element].self, forKey: .overlay, configuration: configuration)
            }

        try self.init(
            id: screenId,
            layoutBehaviour: layoutBehaviour,
            cover: layoutBehaviour == .hero ? container.decodeIfPresent(Schema.Box.self, forKey: .cover, configuration: configuration) : nil,
            content: container.decode(Schema.Element.self, forKey: .content, configuration: configuration),
            footer: layoutBehaviour != .default ? container.decodeIfPresent(Schema.Element.self, forKey: .footer, configuration: configuration) : nil,
            overlay: overlay,
            screenActions: Schema.ScreenActions(from: decoder)
        )
    }
}

