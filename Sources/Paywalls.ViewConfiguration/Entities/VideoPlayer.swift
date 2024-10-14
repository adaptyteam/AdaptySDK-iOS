//
//  VideoPlayer.swift
//  AdaptyUI
//
//  Created by Aleksei Valiano on 24.07.2024
//

import Foundation

extension AdaptyUI {
    package struct VideoPlayer: Hashable, Sendable {
        static let defaultAspectRatio = AspectRatio.fit

        package let asset: Mode<VideoData>

        package let aspect: AspectRatio
        package let loop: Bool
    }
}

#if DEBUG
    package extension AdaptyUI.VideoPlayer {
        static func create(
            asset: AdaptyUI.Mode<AdaptyUI.VideoData>,
            aspect: AdaptyUI.AspectRatio = defaultAspectRatio,
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
