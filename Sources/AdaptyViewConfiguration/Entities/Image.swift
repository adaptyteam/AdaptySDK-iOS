//
//  Image.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 25.03.2024
//

import Foundation

extension AdaptyViewConfiguration {
    package struct Image: Sendable, Hashable {
        static let defaultAspectRatio = AspectRatio.fit

        package let asset: Mode<ImageData>
        package let aspect: AspectRatio
        package let tint: Mode<Filling>?
    }
}

#if DEBUG
    package extension AdaptyViewConfiguration.Image {
        static func create(
            asset: AdaptyViewConfiguration.Mode<AdaptyViewConfiguration.ImageData>,
            aspect: AdaptyViewConfiguration.AspectRatio = defaultAspectRatio,
            tint: AdaptyViewConfiguration.Mode<AdaptyViewConfiguration.Filling>? = nil
        ) -> Self {
            .init(
                asset: asset,
                aspect: aspect,
                tint: tint
            )
        }
    }
#endif
