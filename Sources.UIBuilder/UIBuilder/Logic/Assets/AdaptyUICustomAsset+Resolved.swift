//
//  File.swift
//  Adapty
//
//  Created by Alex Goncharov on 14/01/2026.
//

#if canImport(UIKit)

import SwiftUI
import UIKit

extension AdaptyUICustomColorAsset {
    var resolvedColor: AdaptyUIResolvedColorAsset {
        switch self {
        case .uiColor(let color):
            SwiftUI.Color(color)
        case .swiftUIColor(let color):
            color
        }
    }
}

extension AdaptyUICustomGradientAsset {
    var resolvedGradient: AdaptyUIResolvedGradientAsset {
        switch self {
        case .linear(let gradient, let start, let end):
            .linear(
                LinearGradient(
                    gradient: gradient,
                    startPoint: start,
                    endPoint: end
                )
            )
        case .angular(let gradient, let center, let angle):
            .angular(
                AngularGradient(
                    gradient: gradient,
                    center: center,
                    angle: angle
                )
            )
        case .radial(let gradient, let center, let startRadius, let endRadius):
            .radial(
                RadialGradient(
                    gradient: gradient,
                    center: center,
                    startRadius: startRadius,
                    endRadius: endRadius
                )
            )
        }
    }
}

extension AdaptyUICustomImageAsset {
    var resolvedImage: AdaptyUIResolvedImageAsset? {
        switch self {
        case .file(let url):
            guard let data = try? Data(contentsOf: url), let value = UIImage(data: data) else { return nil }
            return .image(image: value)
        case .remote(let url, let preview):
            return .remote(url: url, preview: preview)
        case .uiImage(let value):
            return .image(image: value)
        }
    }
}

import AVKit

extension AdaptyUICustomVideoAsset {
    var resolvedVideo: AdaptyUIResolvedVideoAsset {
        switch self {
        case .file(let url, let preview),
             .remote(let url, let preview):
            let playerItem = AVPlayerItem(url: url)
            let queuePlayer = AVQueuePlayer(items: [playerItem])
            queuePlayer.isMuted = true
            return .init(
                player: queuePlayer,
                item: playerItem,
                image: preview.flatMap(\.resolvedImage)
            )
        case .player(let item, let player, let preview):
            return .init(
                player: player,
                item: item,
                image: preview.flatMap(\.resolvedImage)
            )
        }
    }
}

extension AdaptyUICustomAsset {
    func resolved() -> AdaptyUIResolvedAsset? {
        switch self {
        case .color(let color):
            .color(color.resolvedColor)
        case .gradient(let gradient):
            .colorGradient(gradient.resolvedGradient)
        case .image(let image):
            if let resolvedImage = image.resolvedImage {
                .image(resolvedImage)
            } else {
                AdaptyUIResolvedAsset?.none
            }
        case .video(let video):
            .video(video.resolvedVideo)
        case .font(let font): // TODO: default color of Custom fonts
            .font(font, defaultColor: SwiftUI.Color(UIColor.adaptyDefaultTextColor))
        }
    }
}

#endif
