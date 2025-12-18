//
//  Schema.Screen.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 28.03.2024
//

import Foundation

extension Schema {
    struct Screen: Sendable, Hashable {
        let templateId: String
        let backgroundAssetId: String?
        let cover: Box?
        let content: Element
        let footer: Element?
        let overlay: Element?
    }
}

extension Schema.Localizer {
    func screen(_ from: Schema.Screen) throws -> VC.Screen {
        try .init(
            templateId: from.templateId,
            background: from.backgroundAssetId.flatMap { try? background($0) } ?? .default,
            cover: from.cover.map(box),
            content: element(from.content),
            footer: from.footer.map(element),
            overlay: from.overlay.map(element)
        )
    }
}

extension Schema.Screen: Encodable, DecodableWithConfiguration {
    enum CodingKeys: String, CodingKey {
        case templateId = "template_id"
        case backgroundAssetId = "background"
        case cover
        case content
        case footer
        case overlay
    }

    init(from decoder: any Decoder, configuration: Schema.DecodingConfiguration) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let templateId: String

        if container.contains(.templateId) {
            templateId = try container.decode(String.self, forKey: .templateId)
        } else if let value = configuration.legacyTemplateId {
            templateId = value
        } else {
            throw DecodingError.keyNotFound(CodingKeys.templateId, .init(codingPath: decoder.codingPath, debugDescription: "Not found required key: template_id"))
        }

        try self.init(
            templateId: templateId,
            backgroundAssetId: container.decodeIfPresent(String.self, forKey: .backgroundAssetId),
            cover: container.decodeIfPresent(Schema.Box.self, forKey: .cover, configuration: configuration),
            content: container.decode(Schema.Element.self, forKey: .content, configuration: configuration),
            footer: container.decodeIfPresent(Schema.Element.self, forKey: .footer, configuration: configuration),
            overlay: container.decodeIfPresent(Schema.Element.self, forKey: .overlay, configuration: configuration)
        )
    }
}
