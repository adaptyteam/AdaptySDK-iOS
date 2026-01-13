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
        case image(ImageData)
        case video(VideoData)
        case font(Font)
        case unknown(String?)
    }
}

extension VC.Asset {
    var customId: String? {
        switch self {
        case .solidColor(let v): v.customId
        case .colorGradient(let v): v.customId
        case .image(let v): v.customId
        case .video(let v): v.customId
        case .font(let v): v.customId
        case .unknown: nil
        }
    }
}
