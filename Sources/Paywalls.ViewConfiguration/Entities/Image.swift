//
//  Image.swift
//  AdaptyUI
//
//  Created by Aleksei Valiano on 25.03.2024
//

import Foundation

extension AdaptyUICore {
    package struct Image: Sendable, Hashable {
        static let defaultAspectRatio = AspectRatio.fit

        package let asset: Mode<ImageData>
        package let aspect: AspectRatio
        package let tint: Mode<Filling>?
    }
}

#if DEBUG
    package extension AdaptyUICore.Image {
        static func create(
            asset: AdaptyUICore.Mode<AdaptyUICore.ImageData>,
            aspect: AdaptyUICore.AspectRatio = defaultAspectRatio,
            tint: AdaptyUICore.Mode<AdaptyUICore.Filling>? = nil
        ) -> Self {
            .init(
                asset: asset,
                aspect: aspect,
                tint: tint
            )
        }
    }
#endif
