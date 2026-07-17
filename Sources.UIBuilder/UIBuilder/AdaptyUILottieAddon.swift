//
//  AdaptyUILottieAddon.swift
//  AdaptyUIBuilder
//
//  Proof of concept: optional animation renderer injection.
//  The Lottie dependency lives only in the optional AdaptyLottie target; core keeps
//  just this typed seam, so apps that don't link AdaptyLottie don't link Lottie.
//

#if canImport(UIKit)

import SwiftUI

/// Typed renderer contract for the `lottie` element. Implemented by the optional
/// `AdaptyLottie` target (or a custom implementation on version conflicts).
public protocol AdaptyUILottieAddon {
    @MainActor func makeView(context: AdaptyUILottieContext) -> AnyView
}

/// Data passed to a Lottie addon at render time.
public struct AdaptyUILottieContext: Sendable {
    public let animationId: String

    /// Text overrides keyed by animation keypath (usually the AE layer name), e.g. ["Text 1": "Hello"].
    /// Empty means "keep the text authored in the animation".
    public let texts: [String: String]

    /// Color overrides: animation keypath -> "#RRGGBB" / "#RRGGBBAA".
    /// The keypath ends with the property name, e.g. "Text 1.Color" or "Shape.Fill 1.Color".
    public let colors: [String: String]

    /// Playback loop mode.
    public let loop: AdaptyUILottieLoop
    /// Playback speed multiplier (1.0 == authored speed).
    public let speed: Double
    /// When false the animation stays paused on its current frame.
    public let autoplay: Bool
    /// How the animation is fitted into the element's frame.
    public let fit: AdaptyUILottieFit

    public init(
        animationId: String,
        texts: [String: String] = [:],
        colors: [String: String] = [:],
        loop: AdaptyUILottieLoop = .loop,
        speed: Double = 1.0,
        autoplay: Bool = true,
        fit: AdaptyUILottieFit = .fit
    ) {
        self.animationId = animationId
        self.texts = texts
        self.colors = colors
        self.loop = loop
        self.speed = speed
        self.autoplay = autoplay
        self.fit = fit
    }
}

#endif
