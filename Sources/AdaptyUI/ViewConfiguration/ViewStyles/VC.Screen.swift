//
//  VC.Screen.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 28.03.2024
//
//

import Foundation

extension AdaptyUI.ViewConfiguration {
    struct Screen {
        let backgroundAssetId: String
        let mainImage: Image?
        let mainBlock: Stack?
        let footerBlock: Stack?
    }
}

extension AdaptyUI.ViewConfiguration.Localizer {
    func screen(from: AdaptyUI.ViewConfiguration.Screen) -> AdaptyUI.Screen {
        .init(
            background: fillingIfPresent(from.backgroundAssetId) ?? AdaptyUI.Screen.default.background,
            mainImage: from.mainImage.map(image),
            mainBlock: from.mainBlock.map(stack),
            footerBlock: from.footerBlock.map(stack)
        )
    }
}
