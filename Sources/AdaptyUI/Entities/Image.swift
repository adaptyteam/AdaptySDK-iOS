//
//  Image.swift
//  AdaptyUI
//
//  Created by Aleksei Valiano on 25.03.2024
//

import Foundation

extension AdaptyUI {
    package struct Image {
        static let defaultAspectRatio = AspectRatio.fit

        package let asset: ImageData
        package let aspect: AspectRatio
        package let tint: ColorFilling?
    }
}

#if DEBUG
    package extension AdaptyUI.Image {
        static func create(
            asset: AdaptyUI.ImageData,
            aspect: AdaptyUI.AspectRatio = defaultAspectRatio,
            tint: AdaptyUI.ColorFilling? = nil
        ) -> Self {
            .init(
                asset: asset,
                aspect: aspect,
                tint: tint
            )
        }
    }
#endif
