//
//  Schema.Screen.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 28.03.2024
//

import Foundation

extension Schema {
    struct Screen: Sendable, Hashable {
        let backgroundAssetId: String?
        let cover: Box?
        let content: Element
        let footer: Element?
        let overlay: Element?
        let selectedAdaptyProductId: String?
    }
}

extension Schema.Localizer {
    func screen(_ from: Schema.Screen) throws -> VC.Screen {
        try .init(
            background: from.backgroundAssetId.flatMap { try? background($0) } ?? .default,
            cover: from.cover.map(box),
            content: element(from.content),
            footer: from.footer.map(element),
            overlay: from.overlay.map(element),
            selectedAdaptyProductId: from.selectedAdaptyProductId
        )
    }

    func bottomSheet(_ from: Schema.Screen) throws -> VC.BottomSheet {
        try .init(
            content: element(from.content)
        )
    }
}

extension Schema.Screen: Encodable, DecodableWithConfiguration {
    enum CodingKeys: String, CodingKey {
        case backgroundAssetId = "background"
        case cover
        case content
        case footer
        case overlay
        case selectedAdaptyProductId = "selected_product"
    }

    init(from decoder: any Decoder, configuration: Schema.DecodingConfiguration) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            backgroundAssetId: container.decodeIfPresent(String.self, forKey: .backgroundAssetId),
            cover: container.decodeIfPresent(Schema.Box.self, forKey: .cover, configuration: configuration),
            content: container.decode(Schema.Element.self, forKey: .content, configuration: configuration),
            footer: container.decodeIfPresent(Schema.Element.self, forKey: .footer, configuration: configuration),
            overlay: container.decodeIfPresent(Schema.Element.self, forKey: .overlay, configuration: configuration),
            selectedAdaptyProductId: container.decodeIfPresent(String.self, forKey: .selectedAdaptyProductId)
        )
    }
}

