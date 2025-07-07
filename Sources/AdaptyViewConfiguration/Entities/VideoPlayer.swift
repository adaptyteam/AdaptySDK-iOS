//
//  VideoPlayer.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 24.07.2024
//

import Foundation

extension AdaptyViewConfiguration {
    package struct VideoPlayer: Hashable, Sendable {
        static let defaultAspectRatio = AspectRatio.fit

        package let asset: Mode<VideoData>

        package let aspect: AspectRatio
        package let loop: Bool
    }
}

#if DEBUG
package extension AdaptyViewConfiguration.VideoPlayer {
    static func create(
        asset: AdaptyViewConfiguration.Mode<AdaptyViewConfiguration.VideoData>,
        aspect: AdaptyViewConfiguration.AspectRatio = defaultAspectRatio,
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
