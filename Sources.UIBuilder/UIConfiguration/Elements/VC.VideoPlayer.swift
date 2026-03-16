//
//  VC.VideoPlayer.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 24.07.2024
//

import Foundation

extension VC {
    struct VideoPlayer: Hashable, Sendable {
        let asset: AssetReference
        let aspect: AspectRatio
        let loop: Bool
    }
}
