//
//  VC.Screen.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 28.03.2024
//

import Foundation

extension AdaptyViewSource {
    struct Screen: Sendable, Hashable {
        let backgroundAssetId: String?
        let cover: Box?
        let content: Element
        let footer: Element?
        let overlay: Element?
        let selectedAdaptyProductId: String?
    }
}

extension AdaptyViewSource.Localizer {
    func screen(_ from: AdaptyViewSource.Screen) throws -> AdaptyViewConfiguration.Screen {
        try .init(
            background: from.backgroundAssetId.flatMap { try? background($0) } ?? AdaptyViewConfiguration.Screen.defaultBackground,
            cover: from.cover.map(box),
            content: element(from.content),
            footer: from.footer.map(element),
            overlay: from.overlay.map(element),
            selectedAdaptyProductId: from.selectedAdaptyProductId
        )
    }

    func bottomSheet(_ from: AdaptyViewSource.Screen) throws -> AdaptyViewConfiguration.BottomSheet {
        try .init(
            content: element(from.content)
        )
    }
}

extension AdaptyViewSource.Screen: Codable {
    enum CodingKeys: String, CodingKey {
        case backgroundAssetId = "background"
        case cover
        case content
        case footer
        case overlay
        case selectedAdaptyProductId = "selected_product"
    }
}
