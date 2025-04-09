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
    func aspectRatio(_ aspect: VC.AspectRatio) -> some View {
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
        case image(VC.Image)
        case raw(VC.ImageData, VC.AspectRatio, VC.Filling?)
    }

    private var data: InitializationMode

    init(
        asset: VC.ImageData,
        aspect: VC.AspectRatio,
        tint: VC.Filling? = nil
    ) {
        data = .raw(asset, aspect, tint)
    }

    init(
        _ image: VC.Image
    ) {
        data = .image(image)
    }

    @Environment(\.colorScheme)
    private var colorScheme: ColorScheme
    @EnvironmentObject
    private var assetsViewModel: AdaptyAssetsViewModel

    @ViewBuilder
    private func rasterImage(
        _ uiImage: UIImage?,
        aspect: VC.AspectRatio,
        tint: VC.Filling?
    ) -> some View {
        if let uiImage {
            if let tint = tint?.asSolidColor?.swiftuiColor {
                Image(uiImage: uiImage)
                    .resizable()
                    .renderingMode(.template)
                    .foregroundColor(tint(assetsViewModel.assetsResolver))
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
    private func resolvedCustomImage(
        customAsset: AdaptyCustomImageAsset,
        aspect: VC.AspectRatio,
        tint: VC.Filling?
    ) -> some View {
        switch customAsset {
        case let .file(url):
            if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                rasterImage(
                    image,
                    aspect: aspect,
                    tint: tint
                )
            } else {
                EmptyView()
            }
        case let .remote(url, preview):
            KFImage
                .url(url)
                .resizable()
                .aspectRatio(aspect)
                .background {
                    if let preview {
                        rasterImage(preview, aspect: aspect, tint: tint)
                    } else {
                        EmptyView()
                    }
                }
        case let .uiImage(value):
            rasterImage(
                value,
                aspect: aspect,
                tint: tint
            )
        }
    }

    @ViewBuilder
    private func resolvedSchemeBody(
        asset: VC.ImageData,
        aspect: VC.AspectRatio,
        tint: VC.Filling?
    ) -> some View {
        switch asset {
        case let .raster(customId, data):
            if let customId,
               case let .image(customAsset) = assetsViewModel.assetsResolver.asset(for: customId)
            {
                resolvedCustomImage(
                    customAsset: customAsset,
                    aspect: aspect,
                    tint: tint
                )
            } else {
                rasterImage(
                    UIImage(data: data),
                    aspect: aspect,
                    tint: tint
                )
            }
        case let .url(customId, url, preview):
            if let customId,
               case let .image(customAsset) = assetsViewModel.assetsResolver.asset(for: customId)
            {
                resolvedCustomImage(
                    customAsset: customAsset,
                    aspect: aspect,
                    tint: tint
                )
            } else {
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
