//
//  AdaptyUIImageView.swift
//
//
//  Created by Aleksey Goncharov on 2.4.24..
//

#if canImport(UIKit)

import SwiftUI
import UIKit

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
    private var assetsViewModel: AdaptyUIAssetsViewModel

    @ViewBuilder
    private func rasterImage(
        _ uiImage: UIImage?,
        aspect: VC.AspectRatio,
        tint: VC.Color.Resolved?
    ) -> some View {
        if let uiImage {
            if let tint = tint {
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
        asset: VC.ImageData.Resolved,
        aspect: VC.AspectRatio,
        tint: VC.Color.Resolved?
    ) -> some View {
        switch asset {
        case let .image(image):
            rasterImage(image, aspect: aspect, tint: tint)
        case let .remote(url, preview):
            KFImage
                .url(url)
                .targetCache(AdaptyUIBuilder.imageCache)
                .onSuccess { res in
                    Log.ui.verbose("IMG load success, cache: \(res.cacheType), url: \(url)")
                }
                .onFailure { error in
                    Log.ui.verbose("IMG load error, \(error), url: \(url)")
                }
                .resizable()
                .placeholder {
                    if let preview {
                        rasterImage(preview, aspect: aspect, tint: tint)
                    } else {
                        EmptyView()
                    }
                }
                .aspectRatio(aspect)
        }
    }

    var body: some View {
        switch data {
        case let .image(image):
            resolvedSchemeBody(
                asset: image.asset.resolve(with: assetsViewModel.assetsResolver, colorScheme: colorScheme),
                aspect: image.aspect,
                tint: image.tint?.asSolidColor?.resolve(with: assetsViewModel.assetsResolver, colorScheme: colorScheme)
            )
        case let .raw(asset, aspect, tint):
            resolvedSchemeBody(
                asset: asset.resolve(with: assetsViewModel.assetsResolver),
                aspect: aspect,
                tint: tint?.asSolidColor?.resolve(with: assetsViewModel.assetsResolver)
            )
        }
    }
}

#endif
