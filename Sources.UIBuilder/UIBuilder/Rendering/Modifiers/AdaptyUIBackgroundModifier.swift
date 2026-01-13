//
//  AdaptyUIBackgroundModifier.swift
//
//
//  Created by Aleksey Goncharov on 17.06.2024.
//

#if canImport(UIKit)

import SwiftUI

extension ColorScheme {
    var toVCMode: VC.Mode {
        switch self {
        case .dark: .dark
        default: .light
        }
    }
}

struct AdaptyUIBackgroundModifier: ViewModifier {
    var background: VC.AssetReference?
    var defaultValue: VC.Asset?

    @EnvironmentObject
    private var assetsViewModel: AdaptyUIAssetsViewModel
    @EnvironmentObject
    private var stateViewModel: AdaptyUIStateViewModel
    @Environment(\.colorScheme)
    private var colorScheme: ColorScheme

    private func withImageBackground(
        content: Content,
        imageData: VC.ImageData.Resolved
    ) -> some View {
        content
            .background {
                AdaptyUIImageView(
                    asset: imageData,
                    aspect: .fill
                )
                .ignoresSafeArea()
            }
    }

    private func withSolidColorBackground(
        content: Content,
        color: VC.Color.Resolved
    ) -> some View {
        content
            .background {
                Rectangle()
                    .fillSolidColor(color)
                    .ignoresSafeArea()
            }
    }

    private func withColorGradientBackground(
        content: Content,
        gradient: VC.ColorGradient.Resolved
    ) -> some View {
        content
            .background {
                Rectangle()
                    .fillColorGradient(gradient)
                    .ignoresSafeArea()
            }
    }

    @ViewBuilder
    func defaultAssetBackground(content: Content, asset: VC.Asset?) -> some View {
        switch asset {
        case let .image(imageData):
            withImageBackground(
                content: content,
                imageData: imageData.resolved
            )
        case let .solidColor(color):
            withSolidColorBackground(
                content: content,
                color: color.resolved
            )
        case let .colorGradient(gradient):
            withColorGradientBackground(
                content: content,
                gradient: gradient.resolved
            )
        case .font, .video, .unknown, .none:
            content
        }
    }

    func body(content: Content) -> some View {
        let asset = stateViewModel.asset(
            background,
            mode: colorScheme.toVCMode,
            defaultValue: .defaultScreenBackground
        )

        if let customId = asset?.customId,
           let customAsset = assetsViewModel.assetsResolver.asset(for: customId)
        {
            switch customAsset {
            case let .image(customImageAsset):
                if let resolvedCustomAsset = customImageAsset.resolved {
                    withImageBackground(
                        content: content,
                        imageData: resolvedCustomAsset
                    )
                } else {
                    defaultAssetBackground(
                        content: content,
                        asset: asset
                    )
                }
            case let .color(customColorAsset):
                withSolidColorBackground(
                    content: content,
                    color: customColorAsset.resolved
                )
            case let .gradient(customGradientAsset):
                withColorGradientBackground(
                    content: content,
                    gradient: customGradientAsset
                )
            case .video, .font:
                defaultAssetBackground(
                    content: content,
                    asset: asset
                )
            }
        } else {
            defaultAssetBackground(content: content, asset: asset)
        }
    }
}

extension View {
    @ViewBuilder
    func staticBackground(
        _ background: VC.AssetReference?,
        defaultValue: VC.Asset?
    ) -> some View {
        if let background {
            modifier(
                AdaptyUIBackgroundModifier(
                    background: background,
                    defaultValue: defaultValue
                )
            )
        } else {
            self
        }
    }
}

#endif
