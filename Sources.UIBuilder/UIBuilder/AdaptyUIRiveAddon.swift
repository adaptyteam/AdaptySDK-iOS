//
//  AdaptyUIRiveAddon.swift
//  AdaptyUIBuilder
//
//  Proof of concept: optional Rive renderer injection.
//  The Rive dependency lives only in the optional AdaptyRive target; core keeps
//  just this typed seam, so apps that don't link AdaptyRive don't link Rive.
//

#if canImport(UIKit)

import SwiftUI

/// Typed renderer contract for the `rive` element. Implemented by the optional
/// `AdaptyRive` target (or a custom implementation on version conflicts).
public protocol AdaptyUIRiveAddon {
    @MainActor func makeView(context: AdaptyUIRiveContext) -> AnyView
}

/// Data passed to a Rive addon at render time.
public struct AdaptyUIRiveContext: Sendable {
    public let animationId: String

    /// Optional artboard name. `nil` means "use the file's default artboard".
    public let artboard: String?

    /// Optional state machine name. `nil` means "use the artboard's default state machine".
    /// Playback goes through a state machine — the new rive-ios runtime does not play
    /// bare linear animations.
    public let stateMachine: String?

    /// How the animation is fitted into the element's frame.
    public let fit: AdaptyUIRiveFit

    /// When false the state machine does not start automatically.
    public let autoplay: Bool

    /// Data-binding values to inject into the view model, keyed by property path,
    /// e.g. ["health": .number(25)]. Empty means "leave the file's defaults".
    public let values: [String: AdaptyUIRiveValue]

    /// View-model trigger paths to fire once on load, e.g. ["gameOver"].
    public let triggers: [String]

    public init(
        animationId: String,
        artboard: String? = nil,
        stateMachine: String? = nil,
        fit: AdaptyUIRiveFit = .fit,
        autoplay: Bool = true,
        values: [String: AdaptyUIRiveValue] = [:],
        triggers: [String] = []
    ) {
        self.animationId = animationId
        self.artboard = artboard
        self.stateMachine = stateMachine
        self.fit = fit
        self.autoplay = autoplay
        self.values = values
        self.triggers = triggers
    }
}

#endif
