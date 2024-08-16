//
//  VC.Screen.swift
//  AdaptyUI
//
//  Created by Aleksei Valiano on 28.03.2024
//
//

import Foundation

extension AdaptyUI.ViewConfiguration {
    struct Screen: Sendable, Hashable  {
        let backgroundAssetId: String?
        let cover: Box?
        let content: Element
        let footer: Element?
        let overlay: Element?
        let selectedAdaptyProductId: String?
    }
}

extension AdaptyUI.ViewConfiguration.Localizer {
    func screen(_ from: AdaptyUI.ViewConfiguration.Screen) throws -> AdaptyUI.Screen {
        try .init(
            background: from.backgroundAssetId.flatMap { try? filling($0) } ?? AdaptyUI.Screen.defaultBackground,
            cover: from.cover.map(box),
            content: element(from.content),
            footer: from.footer.map(element),
            overlay: from.overlay.map(element),
            selectedAdaptyProductId: from.selectedAdaptyProductId
        )
    }

    func bottomSheet(_ from: AdaptyUI.ViewConfiguration.Screen) throws -> AdaptyUI.BottomSheet {
        try .init(
            content: element(from.content)
        )
    }
}

extension AdaptyUI.ViewConfiguration.Screen: Decodable {
    enum CodingKeys: String, CodingKey {
        case backgroundAssetId = "background"
        case cover
        case content
        case footer
        case overlay
        case selectedAdaptyProductId = "selected_product"
    }
}
