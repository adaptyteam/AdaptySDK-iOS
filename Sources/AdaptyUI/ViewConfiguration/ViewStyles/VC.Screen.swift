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

extension AdaptyUI.ViewConfiguration.Screen {
    func convert(_ localizer: AdaptyUI.ViewConfiguration.Localizer) -> AdaptyUI.Screen {
        .init(
            background: localizer.fillingIfPresent(backgroundAssetId) ?? AdaptyUI.Screen.default.background,
            mainImage: mainImage.map { $0.convert(localizer) },
            mainBlock: mainBlock.map { $0.convert(localizer) },
            footerBlock: footerBlock.map { $0.convert(localizer) }
        )
    }
}
