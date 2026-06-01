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

@MainActor
extension AdaptyUICustomVideoAsset {
    func resolvedVideo(id: String) -> AdaptyUIResolvedVideoAsset {
        switch self {
        case .file(let url, let preview, let resolution),
             .remote(let url, let preview, let resolution):
            return .init(
                id: id,
                asset: AVAsset(url: url),
                image: preview.flatMap(\.resolvedImage),
                ratio: resolution.flatMap(\.aspectRatio)
            )
        case .player(let item, _, let preview, let resolution):
            return .init(
                id: id,
                asset: item.asset,
                image: preview.flatMap(\.resolvedImage),
                ratio: resolution.flatMap(\.aspectRatio)
            )
        }
    }
}

private extension CGSize {
    var aspectRatio: Double? {
        guard width > 0, height > 0 else { return nil }
        return Double(width) / Double(height)
    }
}

@MainActor
extension AdaptyUICustomAsset {
    func resolved(id: String) -> AdaptyUIResolvedAsset? {
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
            .video(video.resolvedVideo(id: id))
        case .font(let font):
            .font(
                .init(
                    font: font.font,
                    defaultColor: font.defaultColor?.resolvedColor
                        ?? SwiftUI.Color(UIColor.adaptyDefaultTextColor),
                    defaultLetterSpacing: font.defaultLetterSpacing,
                    defaultLineHeight: font.defaultLineHeight
                )
            )
        }
    }
}

#endif
