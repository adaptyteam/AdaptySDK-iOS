//
//  AdaptyUIAnimatedBackgroundModifier.swift
//  Adapty
//
//  Created by Alex Goncharov on 17/02/2026.
//

#if canImport(UIKit)

import SwiftUI

struct AdaptyUIAnimatedBackgroundModifier: ViewModifier {
    private var play: Binding<VC.Animation.Background?>
    private var initialBackground: VC.AssetReference?
    private var defaultColor: Color

    init(
        play: Binding<VC.Animation.Background?>,
        initialBackground: VC.AssetReference? = nil,
        defaultColor: Color
    ) {
        self.play = play
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

    func body(content: Content) -> some View {
        bodyWithBackground(content: content)
            .onChange(of: play.wrappedValue) { animation in
                if let animation {
                    startAnimation(animation)
                }
            }
            .onDisappear {
                animationTokens.forEach { $0.invalidate() }
                animationTokens.removeAll()
            }
    }

    @ViewBuilder
    private func bodyWithBackground(
        content: Content
    ) -> some View {
        if let animatedBackgroundFilling,
           let asset = assetsViewModel.resolvedAsset(
               animatedBackgroundFilling,
               mode: colorScheme.toVCMode,
               screen: screen
           ).asColorOrGradientOrImageAsset
        {
            bodyWithResolvedBackground(
                content: content,
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
                content: content,
                asset: asset
            )
        }
        else {
            content
                .background {
                    Rectangle()
                        .fillSolidColor(defaultColor)
                        .ignoresSafeArea()
                }
        }
    }

    @ViewBuilder
    private func bodyWithResolvedBackground(
        content: Content,
        asset: AdaptyUIResolvedColorOrGradientOrImageAsset?
    ) -> some View {
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

    private func startAnimation(_ animation: VC.Animation.Background) {
        var tokens = Set<AdaptyUIAnimationToken>()

        tokens.insert(
            animation.timeline.animate(
                from: animation.range.start,
                to: animation.range.end,
                updateBlock: { self.animatedBackgroundFilling = $0 }
                // TODO: x add finish block and finish value
            )
        )

        animationTokens = tokens
    }
}

extension View {
    @ViewBuilder
    func animatedBackground(
        play: Binding<VC.Animation.Background?>,
        initialBackground: VC.AssetReference?,
        defaultColor: Color
    ) -> some View {
        modifier(
            AdaptyUIAnimatedBackgroundModifier(
                play: play,
                initialBackground: initialBackground,
                defaultColor: defaultColor
            )
        )
    }
}

#endif
