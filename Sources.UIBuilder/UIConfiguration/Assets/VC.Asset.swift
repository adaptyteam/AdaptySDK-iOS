//
//  VC.Asset.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 24.12.2025.
//

import Foundation

extension VC {
    enum Asset: Sendable, Hashable {
        case solidColor(Color)
        case colorGradient(ColorGradient)
//        case filling(Filling)
        case image(ImageData)
        case video(VideoData)
        case font(Font)
        case unknown(String?)
    }
}


