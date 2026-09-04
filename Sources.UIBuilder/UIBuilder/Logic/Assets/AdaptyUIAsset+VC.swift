//
//  AdaptyUIAsset+VC.swift
//  AdaptyUIBuilder
//
//  Created by Alex Goncharov on 20/08/2026.
//

#if canImport(UIKit)

import SwiftUI
import UIKit

package extension VC.Color {
    var asCustomAsset: AdaptyUICustomAsset {
        .color(.swiftUIColor(resolvedColor))
    }
}

package extension VC.ColorGradient {
    var asCustomAsset: AdaptyUICustomAsset {
        .gradient(asGradientAsset)
    }

    // Mirrors `resolvedGradient`, so a gradient passed through the cross-platform
    // bridge is mapped exactly like the same gradient coming from the backend.
    var asGradientAsset: AdaptyUIGradientAsset {
        switch kind {
        case .linear:
            .linear(
                gradient: .init(stops: stops),
                startPoint: start.unitPoint,
                endPoint: end.unitPoint
            )
        case .conic:
            .angular(
                gradient: .init(stops: stops),
                center: start.unitPoint,
                angle: .degrees(360)
            )
        case .radial:
            .radial(
                gradient: .init(stops: stops),
                center: start.unitPoint,
                startRadius: end.x,
                endRadius: end.y
            )
        }
    }
}

extension VC.DataAsset {
    var asDataAsset: AdaptyUIDataAsset {
        switch source {
        case let .value(data):
            .init(format: format, value: data)
        case let .url(url):
            .init(format: format, url: url)
        }
    }
}

extension VC.ImageData {
    var asImageAsset: AdaptyUIImageAsset? {
        switch self {
        case let .raster(_, data):
            UIImage(data: data).map { .uiImage(value: $0) }
        case let .url(_, url, previewRaster):
            .remote(url: url, preview: previewRaster.flatMap(UIImage.init))
        }
    }
}

extension VC.Asset {
    /// Configuration asset in the public type the app reads assets in. Unknown
    /// assets have no public representation.
    @MainActor
    var asAsset: AdaptyUIAsset? {
        switch self {
        case let .solidColor(color):
            .color(color.resolvedColor)
        case let .colorGradient(gradient):
            .gradient(gradient.asGradientAsset)
        case let .image(image):
            image.asImageAsset.map(AdaptyUIAsset.image)
        case let .video(video):
            .video(
                .remote(
                    url: video.url,
                    preview: video.image.asImageAsset,
                    resolution: video.horizontalResolution > 0 && video.verticalResolution > 0
                        ? CGSize(width: video.horizontalResolution, height: video.verticalResolution)
                        : nil
                )
            )
        case let .font(font):
            .font(
                .init(
                    font: .create(font, withSize: font.defaultSize),
                    color: font.defaultColor.resolvedColor,
                    letterSpacing: font.defaultLetterSpacing,
                    lineHeight: font.defaultLineHeight
                )
            )
        case let .data(data):
            .data(data.asDataAsset)
        case .unknown:
            nil
        }
    }
}

#endif
