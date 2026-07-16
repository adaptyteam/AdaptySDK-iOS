//
//  AdaptyUILottieView.swift
//  AdaptyUIBuilder
//
//  PoC: renders the `lottie` element via the injected addon, or falls back
//  (Color.clear + debug warning) when no addon is registered.
//

#if canImport(UIKit)

import SwiftUI

@MainActor
struct AdaptyUILottieView: View {
    private let lottie: VC.Lottie

    init(_ lottie: VC.Lottie) {
        self.lottie = lottie
    }

    var body: some View {
        if let addon = AdaptyUIAddons.lottie {
            addon.makeView(context: .init(
                animationId: lottie.animationId,
                texts: lottie.texts,
                colors: lottie.colors,
                loop: lottie.loop,
                speed: lottie.speed,
                autoplay: lottie.autoplay,
                fit: lottie.fit
            ))
        } else {
            Color.clear
                .onAppear {
                    #if DEBUG
                    Log.ui.error("AdaptyUILottieView: Lottie addon not registered; element '\(lottie.animationId)' skipped")
                    #endif
                }
        }
    }
}

#endif
