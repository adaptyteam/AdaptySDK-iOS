//
//  AdaptyUIResolvedAsset.swift
//  Adapty
//
//  Created by Alex Goncharov on 14/01/2026.
//

#if canImport(UIKit)

import SwiftUI
import UIKit

typealias AdaptyUIResolvedColorAsset = Color
typealias AdaptyUIResolvedFontAsset = UIFont

enum AdaptyUIResolvedGradientAsset {
    case linear(LinearGradient)
    case angular(AngularGradient)
    case radial(RadialGradient)
}

enum AdaptyUIResolvedImageAsset {
    case image(image: UIImage?)
    case remote(url: URL, preview: UIImage?)
}

import AVKit

struct AdaptyUIResolvedVideoAsset {
    let player: AVQueuePlayer
    let item: AVPlayerItem
    let image: AdaptyUIResolvedImageAsset?
}

enum AdaptyUIResolvedAsset {
    case color(AdaptyUIResolvedColorAsset)
    case colorGradient(AdaptyUIResolvedGradientAsset)
    case image(AdaptyUIResolvedImageAsset)

    case video(AdaptyUIResolvedVideoAsset)
    case font(AdaptyUIResolvedFontAsset)

    case nothing
    
    var isNothing: Bool {
        if case .nothing = self {
            true
        } else {
            false
        }
    }
}

extension AdaptyUIResolvedAsset {
    var typeName: String {
        switch self {
        case .color: "color"
        case .colorGradient: "colorGradient"
        case .image: "image"
        case .video: "video"
        case .font: "font"
        case .nothing: "nothing"
        }
    }
}

extension AdaptyUIResolvedAsset {
    var asColorAsset: AdaptyUIResolvedColorAsset? {
        guard case let .color(asset) = self else {
            return nil
        }

        return asset
    }

    var asImageAsset: AdaptyUIResolvedImageAsset? {
        guard case let .image(asset) = self else {
            return nil
        }

        return asset
    }
    
    var asFontAsset: AdaptyUIResolvedFontAsset? {
        guard case let .font(asset) = self else {
            return nil
        }

        return asset
    }
}

#endif
