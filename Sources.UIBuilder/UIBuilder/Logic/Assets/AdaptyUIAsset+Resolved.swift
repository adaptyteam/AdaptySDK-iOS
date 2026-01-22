//
//  File.swift
//  Adapty
//
//  Created by Alex Goncharov on 14/01/2026.
//

#if canImport(UIKit)

import Foundation
import SwiftUI

extension VC.Color {
    var resolvedColor: AdaptyUIResolvedColorAsset {
        SwiftUI.Color(.sRGB, red: red, green: green, blue: blue, opacity: alpha)
    }
}

extension VC.ColorGradient {
    private var stops: [Gradient.Stop] {
        let result = items
            .map { Gradient.Stop(color: $0.color.resolvedColor, location: $0.p) }
            .sorted(by: { $0.location < $1.location })

        return result
    }

    var resolvedGradient: AdaptyUIResolvedGradientAsset {
        switch kind {
        case .linear:
            .linear(
                LinearGradient(
                    gradient: .init(stops: stops),
                    startPoint: start.unitPoint,
                    endPoint: end.unitPoint
                )
            )
        case .conic:
            .angular(
                AngularGradient(
                    gradient: .init(stops: stops),
                    center: .center,
                    angle: .degrees(360)
                )
            )
        case .radial:
            .radial(
                RadialGradient(
                    gradient: .init(stops: stops),
                    center: .center,
                    startRadius: 0.0,
                    endRadius: 1.0
                )
            )
        }
    }
}

extension VC.ImageData {
    var resolvedImage: AdaptyUIResolvedImageAsset {
        switch self {
        case .raster(_, let data):
            return .image(image: UIImage(data: data))
        case .url(_, let url, previewRaster: let previewRaster):
            return .remote(
                url: url,
                preview: previewRaster.flatMap(UIImage.init)
            )
        }
    }
}

import AVKit

extension VC.VideoData {
    var resolvedVideo: AdaptyUIResolvedVideoAsset {
        let item = AVPlayerItem(url: url)
        let player = AVQueuePlayer(items: [item])
        player.isMuted = true

        return AdaptyUIResolvedVideoAsset(
            player: player,
            item: item,
            image: image.resolvedImage
        )
    }
}

extension VC.Asset {
    func resolved() -> AdaptyUIResolvedAsset? {
        switch self {
        case .solidColor(let color):
            .color(color.resolvedColor)
        case .colorGradient(let gradient):
            .colorGradient(gradient.resolvedGradient)
        case .image(let image):
            .image(image.resolvedImage)
        case .video(let video):
            .video(video.resolvedVideo)
        case .font(let font):
            .font(.create(font, withSize: font.defaultSize))
        case .unknown:
            nil
        }
    }
}

#endif
