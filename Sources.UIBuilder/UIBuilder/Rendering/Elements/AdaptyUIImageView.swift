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
        case unresolvedAsset(VC.Image)
        case resolvedAsset(AdaptyUIResolvedAsset)
        case resolvedImageAsset(
            asset: AdaptyUIResolvedImageAsset,
            aspect: VC.AspectRatio,
            tint: AdaptyUIResolvedColorAsset?
        )
    }

    private var initializtion: InitializationMode

    init(
        _ initializtion: InitializationMode
    ) {
        self.initializtion = initializtion
    }

    @Environment(\.colorScheme)
    private var colorScheme: ColorScheme
    @EnvironmentObject
    private var assetsViewModel: AdaptyUIAssetsViewModel
    @EnvironmentObject
    private var paywallViewModel: AdaptyUIPaywallViewModel
    
    @ViewBuilder
    private func rasterImage(
        _ uiImage: UIImage?,
        aspect: VC.AspectRatio,
        tint: AdaptyUIResolvedColorAsset?,
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
    private func resolvedImageAssetBody(
        asset: AdaptyUIResolvedImageAsset,
        aspect: VC.AspectRatio,
        tint: AdaptyUIResolvedColorAsset?
    ) -> some View {
        switch asset {
        case .image(let image):
            rasterImage(
                image,
                aspect: aspect,
                tint: tint,
                limitWidth: true
            )
        case .remote(let url, let preview):
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

    @ViewBuilder
    private func resolvedAssetBody(
        asset: AdaptyUIResolvedAsset,
        aspect: VC.AspectRatio,
        tint: AdaptyUIResolvedColorAsset?
    ) -> some View {
        switch asset {
        case .image(let resolvedImageAsset):
            resolvedImageAssetBody(
                asset: resolvedImageAsset,
                aspect: aspect ?? .fill,
                tint: tint
            )
        default:
            Rectangle()
                .onAppear {
                    paywallViewModel.reportDidFailRendering(
                        with: .wrongAssetType("Expected image, got \(asset.typeName)")
                    )
                }
        }
    }

    var body: some View {
        switch initializtion {
        case .unresolvedAsset(let image):
            let asset = assetsViewModel.resolvedAsset(
                image.asset,
                mode: colorScheme.toVCMode
            )

            let tintAsset = assetsViewModel.resolvedAsset(
                image.tint,
                mode: colorScheme.toVCMode
            )

            resolvedAssetBody(
                asset: asset,
                aspect: image.aspect,
                tint: tintAsset.asColorAsset
            )
        case .resolvedAsset(let asset):
            resolvedAssetBody(
                asset: asset,
                aspect: .fill,
                tint: nil
            )
        case .resolvedImageAsset(let asset, let aspect, let tint):
            resolvedImageAssetBody(
                asset: asset,
                aspect: aspect,
                tint: tint
            )
        }
    }
}

#endif
