//
//  AdaptyUIAddons.swift
//  AdaptyUIBuilder
//
//  Proof of concept: registry of injected animation-renderer addons.
//  Each engine gets a separate, typed slot — the compiler guarantees the correct
//  slot, so registration needs no downcast, marker protocol, or enum discriminator.
//  Populated once at init via `AdaptyUI.register<Engine>Addon(_:)`.
//

#if canImport(UIKit)

public enum AdaptyUIAddons {
    @MainActor public static var lottie: (any AdaptyUILottieAddon)?
    @MainActor public static var rive: (any AdaptyUIRiveAddon)?
}

#endif
