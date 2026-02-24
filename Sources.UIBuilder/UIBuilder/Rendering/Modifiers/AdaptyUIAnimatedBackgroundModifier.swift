//
//  AdaptyUIAnimatedBackgroundModifier.swift
//  Adapty
//
//  Created by Alex Goncharov on 17/02/2026.
//

#if canImport(UIKit)

import SwiftUI

struct AdaptyUIAnimatedBackgroundView: View {
    private var initialBackground: VC.AssetReference?
    private var defaultColor: Color

    @EnvironmentObject
    private var navigatorViewModel: AdaptyUINavigatorViewModel

    @State
    private var backgroundAnimation: VC.Animation.Background?

    init(
        initialBackground: VC.AssetReference?,
        defaultColor: Color
    ) {
        self.initialBackground = initialBackground
        self.defaultColor = defaultColor
    }

    @EnvironmentObject
    private var assetsViewModel: AdaptyUIAssetsViewModel
    @Environment(\.colorScheme)
    private var colorScheme: ColorScheme
    @Environment(\.adaptyScreenInstance)
    private var screen: VS.ScreenInstance

    @State private var animatedBackgroundFilling: VC.AssetReference?
    @State private var animationTokens = Set<AdaptyUIAnimationToken>()

    var body: some View {
        bodyWithBackground()
            .ignoresSafeArea()
            .onReceive(navigatorViewModel.$backgroundAnimation) { anim in
                if let anim {
                    startAnimation(anim)
                }
            }
            .onAppear {
                if let currentAnimation = navigatorViewModel.backgroundAnimation {
                    startAnimation(currentAnimation)
                }
                else {
                    print("")
                }
            }
            .onDisappear {
                animationTokens.forEach { $0.invalidate() }
                animationTokens.removeAll()
            }
    }

    @ViewBuilder
    private func bodyWithBackground(
    ) -> some View {
        if let animatedBackgroundFilling,
           let asset = assetsViewModel.resolvedAsset(
               animatedBackgroundFilling,
               mode: colorScheme.toVCMode,
               screen: screen
           ).asColorOrGradientOrImageAsset
        {
            bodyWithResolvedBackground(
                asset: asset
            )
        }
        else if let initialBackground,
                let asset = assetsViewModel.resolvedAsset(
                    initialBackground,
                    mode: colorScheme.toVCMode,
                    screen: screen
                ).asColorOrGradientOrImageAsset
        {
            bodyWithResolvedBackground(
                asset: asset
            )
        }
        else {
            Rectangle()
                .fillSolidColor(defaultColor)
        }
    }

    @ViewBuilder
    private func bodyWithResolvedBackground(
        asset: AdaptyUIResolvedColorOrGradientOrImageAsset?
    ) -> some View {
        switch asset {
        case .color(let color):
            color
        case .colorGradient(let gradient):
            Rectangle()
                .fillColorGradient(gradient)
        case .image(let image):
            AdaptyUIImageView(
                .resolvedImageAsset(
                    asset: image,
                    aspect: .fill,
                    tint: nil
                )
            )
        case .none:
            Rectangle()
                .fill(.clear)
        }
    }

    private func startAnimation(_ animation: VC.Animation.Background) {
        var tokens = Set<AdaptyUIAnimationToken>()

        tokens.insert(
            animation.timeline.animate(
                from: animation.range.start,
                to: animation.range.end,
                updateBlock: { value in
                    print("#BG# animation to \(value)")
                    self.animatedBackgroundFilling = value
                }
                // TODO: x add finish block and finish value
            )
        )

        animationTokens = tokens
    }
}

#endif
