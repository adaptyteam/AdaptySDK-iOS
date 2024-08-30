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

        package let asset: Mode<ImageData>
        package let aspect: AspectRatio
        package let tint: Mode<Filling>?
    }
}

#if DEBUG
    package extension AdaptyUI.Image {
        static func create(
            asset: AdaptyUI.Mode<AdaptyUI.ImageData>,
            aspect: AdaptyUI.AspectRatio = defaultAspectRatio,
            tint: AdaptyUI.Mode<AdaptyUI.Filling>? = nil
        ) -> Self {
            .init(
                asset: asset,
                aspect: aspect,
                tint: tint
            )
        }
    }
#endif
