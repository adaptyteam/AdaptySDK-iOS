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
        case let .solidColor(v): v.customId
        case let .colorGradient(v): v.customId
        case let .image(v): v.customId
        case let .video(v): v.customId
        case let .font(v): v.customId
        case .unknown: nil
        }
    }
}
