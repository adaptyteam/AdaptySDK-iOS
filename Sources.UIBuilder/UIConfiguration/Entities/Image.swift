//
//  Image.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 25.03.2024
//

import Foundation

extension AdaptyUIConfiguration {
    package struct Image: Sendable, Hashable {
        static let defaultAspectRatio = AspectRatio.fit

        package let asset: Mode<ImageData>
        package let aspect: AspectRatio
        package let tint: Mode<Filling>?
    }
}

#if DEBUG
package extension AdaptyUIConfiguration.Image {
    static func create(
        asset: AdaptyUIConfiguration.Mode<AdaptyUIConfiguration.ImageData>,
        aspect: AdaptyUIConfiguration.AspectRatio = defaultAspectRatio,
        tint: AdaptyUIConfiguration.Mode<AdaptyUIConfiguration.Filling>? = nil
    ) -> Self {
        .init(
            asset: asset,
            aspect: aspect,
            tint: tint
        )
    }
}
#endif
