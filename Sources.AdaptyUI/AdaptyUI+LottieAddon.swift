//
//  AdaptyUI+LottieAddon.swift
//  AdaptyUI
//
//  Proof of concept: public entry to inject a Lottie renderer addon.
//

#if canImport(UIKit)

import AdaptyUIBuilder

public extension AdaptyUI {
    /// Register a renderer for `lottie` elements. Pass `AdaptyLottie()` for the default
    /// implementation, or your own `AdaptyUILottieAddon` (e.g. on Lottie version conflicts).
    @MainActor
    static func registerLottieAddon(_ addon: any AdaptyUILottieAddon) {
        AdaptyUIAddons.lottie = addon
    }
}

#endif
