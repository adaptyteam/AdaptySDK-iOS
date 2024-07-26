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

        package let asset: VideoData

        package let aspect: AspectRatio
        package let loop: Bool
        package let background: AdaptyUI.Color
    }
}

#if DEBUG
    package extension AdaptyUI.VideoPlayer {
        static func create(
            asset: AdaptyUI.VideoData,
            aspect: AdaptyUI.AspectRatio = defaultAspectRatio,
            loop: Bool = true,
            background: AdaptyUI.Color = .transparent
        ) -> Self {
            .init(
                asset: asset,
                aspect: aspect,
                loop: loop,
                background: background
            )
        }
    }
#endif
