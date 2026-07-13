//
//  AdaptyUIBackgroundModifier.swift
//
//
//  Created by Aleksey Goncharov on 17.06.2024.
//

#if canImport(UIKit)

import SwiftUI

struct AdaptyUIBackgroundModifier: ViewModifier {
    var background: VC.AssetReference?
    var defaultValue: VC.Asset?

    @EnvironmentObject
    private var assetsViewModel: AdaptyUIAssetsViewModel
    @Environment(\.colorScheme)
    private var colorScheme: ColorScheme
    @Environment(\.adaptyScreenInstance)
    private var screen: VS.ScreenInstance

    func body(content: Content) -> some View {
        let asset = assetsViewModel.resolvedAsset(
            background,
            mode: colorScheme.toVCMode,
            screen: screen
        ).asColorOrGradientOrImageAsset

        switch asset {
        case .color(let color):
            content
                .background {
                    Rectangle()
                        .fillSolidColor(color)
                        .ignoresSafeArea()
                }
        case .colorGradient(let gradient):
            content
                .background {
                    Rectangle()
                        .fillColorGradient(gradient)
                        .ignoresSafeArea()
                }
        case .image(let image):
            content
                .background {
                    AdaptyUIImageView(
                        .resolvedImageAsset(
                            asset: image,
                            aspect: .fill,
                            tint: nil
                        )
                    )
                    .ignoresSafeArea()
                }
        case .none:
            content
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
