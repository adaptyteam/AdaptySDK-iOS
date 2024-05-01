//
//  VC.Screen.swift
//  AdaptyUI
//
//  Created by Aleksei Valiano on 28.03.2024
//
//

import Foundation

extension AdaptyUI.ViewConfiguration {
    struct Screen {
        let backgroundAssetId: String
        let mainImage: Image?
        let mainBlock: Element?
        let footerBlock: Element?
    }
}

extension AdaptyUI.ViewConfiguration.Localizer {
    func screen(_ from: AdaptyUI.ViewConfiguration.Screen) -> AdaptyUI.Screen {
        .init(
            background: fillingIfPresent(from.backgroundAssetId) ?? AdaptyUI.Screen.default.background,
            mainImage: from.mainImage.map(image),
            mainBlock: from.mainBlock.map(element),
            footerBlock: from.footerBlock.map(element)
        )
    }
}

extension AdaptyUI.ViewConfiguration.Screen: Decodable {
    enum CodingKeys: String, CodingKey {
        case backgroundAssetId = "background"
        case mainImage = "main_image"
        case mainBlock = "main_block"
        case footerBlock = "footer_block"
    }
}
