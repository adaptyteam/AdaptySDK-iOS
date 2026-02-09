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

enum AdaptyUIResolvedColorOrGradientAsset {
    case color(AdaptyUIResolvedColorAsset)
    case colorGradient(AdaptyUIResolvedGradientAsset)
}

enum AdaptyUIResolvedColorOrGradientOrImageAsset {
    case color(AdaptyUIResolvedColorAsset)
    case colorGradient(AdaptyUIResolvedGradientAsset)
    case image(AdaptyUIResolvedImageAsset)
}

enum AdaptyUIResolvedAsset {
    case color(AdaptyUIResolvedColorAsset)
    case colorGradient(AdaptyUIResolvedGradientAsset)
    case image(AdaptyUIResolvedImageAsset)

    case video(AdaptyUIResolvedVideoAsset)
    case font(AdaptyUIResolvedFontAsset, defaultColor: AdaptyUIResolvedColorAsset)
}

extension AdaptyUIResolvedAsset {
    var typeName: String {
        switch self {
        case .color: "color"
        case .colorGradient: "colorGradient"
        case .image: "image"
        case .video: "video"
        case .font: "font"
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

    var asVideoAsset: AdaptyUIResolvedVideoAsset? {
        guard case let .video(asset) = self else {
            return nil
        }

        return asset
    }

    var asColorOrGradientAsset: AdaptyUIResolvedColorOrGradientAsset? {
        switch self {
        case let .color(v): .color(v)
        case let .colorGradient(v): .colorGradient(v)
        default: nil
        }
    }

    var asColorOrGradientOrImageAsset: AdaptyUIResolvedColorOrGradientOrImageAsset? {
        switch self {
        case let .color(v): .color(v)
        case let .colorGradient(v): .colorGradient(v)
        case let .image(v): .image(v)
        default: nil
        }
    }

    var asFontAsset: (font: AdaptyUIResolvedFontAsset, defaultColor: AdaptyUIResolvedColorAsset)? {
        guard case let .font(asset, defaultColor) = self else {
            return nil
        }

        return (asset, defaultColor)
    }
}

#endif
