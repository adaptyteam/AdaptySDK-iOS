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
            if let tint = tint?.asSolidColor?.resolve(with: assetsViewModel.assetsResolver) {
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
        asset: VC.ImageData,
        aspect: VC.AspectRatio,
        tint: VC.Filling?
    ) -> some View {
        switch asset.resolve(with: assetsViewModel.assetsResolver) {
        case let .image(image):
            rasterImage(image, aspect: aspect, tint: tint)
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
        }
    }

    var body: some View {
        switch data {
        case let .image(image):
            resolvedSchemeBody(
                asset: image.asset.usedColorScheme(colorScheme),
                aspect: image.aspect,
                tint: image.tint?.usedColorScheme(colorScheme)
            )
        case let .raw(asset, aspect, tint):
            resolvedSchemeBody(asset: asset, aspect: aspect, tint: tint)
        }
    }
}

#endif
