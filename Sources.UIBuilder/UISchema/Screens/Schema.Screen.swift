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
        let screenActions: ScreenActions
    }
}

extension Schema.Localizer {
    func screen(_ from: Schema.Screen) throws -> VC.Screen {
        try .init(
            id: from.id,
            layoutBehaviour: from.layoutBehaviour,
            cover: from.cover.map(box),
            content: element(from.content),
            footer: from.footer.map(element),
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

        try self.init(
            id: screenId,
            layoutBehaviour: layoutBehaviour,
            cover: layoutBehaviour == .hero ? container.decodeIfPresent(Schema.Box.self, forKey: .cover, configuration: configuration) : nil,
            content: container.decode(Schema.Element.self, forKey: .content, configuration: configuration),
            footer: layoutBehaviour != .default ? container.decodeIfPresent(Schema.Element.self, forKey: .footer, configuration: configuration) : nil,
            screenActions: Schema.ScreenActions(from: decoder)
        )
    }
}
