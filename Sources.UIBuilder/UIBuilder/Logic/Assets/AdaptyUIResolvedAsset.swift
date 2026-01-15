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

// TODO: extract out of here
extension AdaptyUIResolvedImageAsset {
    private var uiImage: UIImage? {
        switch self {
        case let .image(image):
            image
        case .remote(_, preview: _): // TODO: implement this
            nil
        }
    }

    func textAttachmentImage(
        font: UIFont,
        tint: UIColor?
    ) -> UIImage? {
        guard var image = uiImage else { return nil }

        let size = CGSize(width: image.size.width * font.capHeight / image.size.height,
                          height: font.capHeight)

        image = image.imageWith(newSize: size)

        if let tint {
            image = image
                .withRenderingMode(.alwaysTemplate)
                .withTintColor(tint, renderingMode: .alwaysTemplate)
        }

        return image
    }
}

#endif
