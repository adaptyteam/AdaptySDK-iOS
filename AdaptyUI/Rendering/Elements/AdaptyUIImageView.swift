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

@available(iOS 15.0, *)
extension View {
    @ViewBuilder
    func aspectRatio(_ aspect: AdaptyUI.AspectRatio) -> some View {
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

@available(iOS 15.0, *)
struct AdaptyUIImageView: View {
    enum InitializationMode {
        case image(AdaptyUI.Image)
        case raw(AdaptyUI.ImageData, AdaptyUI.AspectRatio, AdaptyUI.Filling?)
    }

    private var data: InitializationMode

    init(
        asset: AdaptyUI.ImageData,
        aspect: AdaptyUI.AspectRatio,
        tint: AdaptyUI.Filling? = nil
    ) {
        data = .raw(asset, aspect, tint)
    }

    init(
        _ image: AdaptyUI.Image
    ) {
        data = .image(image)
    }

    @Environment(\.colorScheme)
    private var colorScheme: ColorScheme

    @ViewBuilder
    private func rasterImage(
        _ uiImage: UIImage?,
        aspect: AdaptyUI.AspectRatio,
        tint: AdaptyUI.Filling?
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
        asset: AdaptyUI.ImageData,
        aspect: AdaptyUI.AspectRatio,
        tint: AdaptyUI.Filling?
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
