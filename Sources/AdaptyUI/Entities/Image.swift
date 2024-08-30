//
//  Image.swift
//  AdaptyUI
//
//  Created by Aleksei Valiano on 25.03.2024
//

import Foundation

extension AdaptyUI {
    package struct Image: Hashable, Sendable {
        static let defaultAspectRatio = AspectRatio.fit

        package let asset: ImageData
        package let aspect: AspectRatio
        package let tint: Filling?
    }
}

#if DEBUG
    package extension AdaptyUI.Image {
        static func create(
            asset: AdaptyUI.ImageData,
            aspect: AdaptyUI.AspectRatio = defaultAspectRatio,
            tint: AdaptyUI.Filling? = nil
        ) -> Self {
            .init(
                asset: asset,
                aspect: aspect,
                tint: tint
            )
        }
    }
#endif
