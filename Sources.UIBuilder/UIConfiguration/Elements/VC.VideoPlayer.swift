//
//  VC.VideoPlayer.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 24.07.2024
//

import Foundation

package extension VC {
    struct VideoPlayer: Hashable, Sendable {
        package let asset: Mode<VideoData>
        package let aspect: AspectRatio
        package let loop: Bool
    }
}

#if DEBUG
package extension VC.VideoPlayer {
    static func create(
        asset: VC.Mode<VC.VideoData>,
        aspect: VC.AspectRatio = .default,
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
