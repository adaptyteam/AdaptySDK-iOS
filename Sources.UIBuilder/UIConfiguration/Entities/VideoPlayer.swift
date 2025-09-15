//
//  VideoPlayer.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 24.07.2024
//

import Foundation

extension AdaptyUIConfiguration {
    package struct VideoPlayer: Hashable, Sendable {
        static let defaultAspectRatio = AspectRatio.fit

        package let asset: Mode<VideoData>

        package let aspect: AspectRatio
        package let loop: Bool
    }
}

#if DEBUG
package extension AdaptyUIConfiguration.VideoPlayer {
    static func create(
        asset: AdaptyUIConfiguration.Mode<AdaptyUIConfiguration.VideoData>,
        aspect: AdaptyUIConfiguration.AspectRatio = defaultAspectRatio,
        loop: Bool = true
    ) -> Self {
        .init(
            asset: asset,
            aspect: aspect,
            loop: loop
        )
    }
}
#endif
