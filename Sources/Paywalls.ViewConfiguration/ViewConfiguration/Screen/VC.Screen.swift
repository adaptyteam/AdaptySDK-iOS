//
//  VC.Screen.swift
//  AdaptyUI
//
//  Created by Aleksei Valiano on 28.03.2024
//
//

import Foundation

extension AdaptyUICore.ViewConfiguration {
    struct Screen: Sendable, Hashable  {
        let backgroundAssetId: String?
        let cover: Box?
        let content: Element
        let footer: Element?
        let overlay: Element?
        let selectedAdaptyProductId: String?
    }
}

extension AdaptyUICore.ViewConfiguration.Localizer {
    func screen(_ from: AdaptyUICore.ViewConfiguration.Screen) throws -> AdaptyUICore.Screen {
        try .init(
            background: from.backgroundAssetId.flatMap { try? background($0) } ?? AdaptyUICore.Screen.defaultBackground,
            cover: from.cover.map(box),
            content: element(from.content),
            footer: from.footer.map(element),
            overlay: from.overlay.map(element),
            selectedAdaptyProductId: from.selectedAdaptyProductId
        )
    }

    func bottomSheet(_ from: AdaptyUICore.ViewConfiguration.Screen) throws -> AdaptyUICore.BottomSheet {
        try .init(
            content: element(from.content)
        )
    }
}

extension AdaptyUICore.ViewConfiguration.Screen: Decodable {
    enum CodingKeys: String, CodingKey {
        case backgroundAssetId = "background"
        case cover
        case content
        case footer
        case overlay
        case selectedAdaptyProductId = "selected_product"
    }
}
