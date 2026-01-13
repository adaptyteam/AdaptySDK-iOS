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
    func aspectRatio(_ aspect: VC.AspectRatio, limitWidth: Bool) -> some View {
        switch aspect {
        case .fit:
            aspectRatio(contentMode: .fit)
        case .fill:
            if limitWidth {
                GeometryReader { proxy in
                    self
                        .aspectRatio(contentMode: .fill)
                        .frame(maxWidth: proxy.size.width)
                }
            } else {
                aspectRatio(contentMode: .fill)
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
        case raw(VC.ImageData.Resolved, VC.AspectRatio)
    }

    private var data: InitializationMode

    init(
        asset: VC.ImageData.Resolved,
        aspect: VC.AspectRatio
    ) {
        data = .raw(asset, aspect)
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
    @EnvironmentObject
    private var stateViewModel: AdaptyUIStateViewModel

    @ViewBuilder
    private func rasterImage(
        _ uiImage: UIImage?,
        aspect: VC.AspectRatio,
        tint: VC.Color.Resolved?,
        limitWidth: Bool
    ) -> some View {
        if let uiImage {
            if let tint = tint {
                Image(uiImage: uiImage)
                    .resizable()
                    .renderingMode(.template)
                    .foregroundColor(tint)
                    .aspectRatio(aspect, limitWidth: limitWidth)

            } else {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(aspect, limitWidth: limitWidth)
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
            rasterImage(
                image,
                aspect: aspect,
                tint: tint,
                limitWidth: true
            )
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
                        rasterImage(
                            preview,
                            aspect: aspect,
                            tint: tint,
                            limitWidth: false
                        )
                    } else {
                        EmptyView()
                    }
                }
                .aspectRatio(aspect, limitWidth: true)
        }
    }

    var body: some View {
        switch data {
        case let .image(image):
            let imageAsset = stateViewModel.asset(
                image.asset,
                mode: colorScheme.toVCMode,
                defaultValue: nil
            )

            let tintAsset = stateViewModel.asset(
                image.tint,
                mode: colorScheme.toVCMode,
                defaultValue: nil
            )

            var tintAssetResolvedColor: VC.Color.Resolved? =
                if let tintCustomId = tintAsset?.customId,
                case let .color(tintCustomColorAsset) = assetsViewModel.assetsResolver.asset(for: tintCustomId) {
                    tintCustomColorAsset.resolved
                } else {
                    tintAsset?.asColor?.resolved
                }

            if let imageAsset,
               case let .image(imageData) = imageAsset
            {
                if let customId = imageData.customId,
                   case let .image(customImageAsset) = assetsViewModel.assetsResolver.asset(for: customId),
                   let resolvedCustomAsset = customImageAsset.resolved
                {
                    resolvedSchemeBody(
                        asset: resolvedCustomAsset,
                        aspect: image.aspect,
                        tint: tintAssetResolvedColor
                    )
                } else {
                    resolvedSchemeBody(
                        asset: imageData.resolved,
                        aspect: image.aspect,
                        tint: tintAssetResolvedColor
                    )
                }
            } else {
                Rectangle()
            }
        case let .raw(asset, aspect):
            resolvedSchemeBody(
                asset: asset,
                aspect: aspect,
                tint: nil
            )
        }
    }
}

#endif
