//
//  AdaptyUIImageView.swift
//
//
//  Created by Aleksey Goncharov on 2.4.24..
//

#if canImport(UIKit)

import Adapty
import SwiftUI
import UIKit

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
extension View {
    @ViewBuilder
    func aspectRatio(_ aspect: AdaptyUICore.AspectRatio) -> some View {
        switch aspect {
        case .fit:
            aspectRatio(contentMode: .fit)
        case .fill:
            // TODO: fix incorrect centering behaviour
            GeometryReader { proxy in
                self
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: proxy.size.width)
            }
        case .stretch:
            self
        }
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
@MainActor
struct AdaptyUIImageView: View {
    enum InitializationMode {
        case image(AdaptyUICore.Image)
        case raw(AdaptyUICore.ImageData, AdaptyUICore.AspectRatio, AdaptyUICore.Filling?)
    }

    private var data: InitializationMode

    init(
        asset: AdaptyUICore.ImageData,
        aspect: AdaptyUICore.AspectRatio,
        tint: AdaptyUICore.Filling? = nil
    ) {
        data = .raw(asset, aspect, tint)
    }

    init(
        _ image: AdaptyUICore.Image
    ) {
        data = .image(image)
    }

    @Environment(\.colorScheme)
    private var colorScheme: ColorScheme

    @ViewBuilder
    private func rasterImage(
        _ uiImage: UIImage?,
        aspect: AdaptyUICore.AspectRatio,
        tint: AdaptyUICore.Filling?
    ) -> some View {
        if let uiImage {
            if let tint = tint?.asSolidColor?.swiftuiColor {
                Image(uiImage: uiImage)
                    .resizable()
                    .renderingMode(.template)
                    .foregroundColor(tint)
                    .aspectRatio(aspect)

            } else {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(aspect)
            }
        } else {
            EmptyView()
        }
    }

    @ViewBuilder
    private func resolvedSchemeBody(
        asset: AdaptyUICore.ImageData,
        aspect: AdaptyUICore.AspectRatio,
        tint: AdaptyUICore.Filling?
    ) -> some View {
        switch asset {
        case let .resources(name):
            rasterImage(UIImage(named: name), aspect: aspect, tint: tint)
        case let .raster(data):
            rasterImage(UIImage(data: data), aspect: aspect, tint: tint)
        case let .url(url, preview):
            KFImage
                .url(url)
                .resizable()
                .aspectRatio(aspect)
                .background {
                    if let preview {
                        let image = UIImage(data: preview)
                        rasterImage(image, aspect: aspect, tint: tint)
                    } else {
                        EmptyView()
                    }
                }
        }
    }

    var body: some View {
        switch data {
        case let .image(image):
            resolvedSchemeBody(
                asset: image.asset.of(colorScheme),
                aspect: image.aspect,
                tint: image.tint?.of(colorScheme)
            )
        case let .raw(asset, aspect, tint):
            resolvedSchemeBody(asset: asset, aspect: aspect, tint: tint)
        }
    }
}

#endif
