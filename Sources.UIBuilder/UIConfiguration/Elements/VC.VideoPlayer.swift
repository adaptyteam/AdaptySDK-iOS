//
//  VC.VideoPlayer.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 24.07.2024
//

import Foundation

package extension VC {
    struct VideoPlayer: Hashable, Sendable {
        package let asset: AssetReference
        package let aspect: AspectRatio
        package let loop: Bool
    }
}
