//
//  AdaptyUI+RiveAddon.swift
//  AdaptyUI
//
//  Proof of concept: public entry to inject a Rive renderer addon.
//

#if canImport(UIKit)

import AdaptyUIBuilder

public extension AdaptyUI {
    /// Register a renderer for `rive` elements. Pass `AdaptyRive()` for the default
    /// implementation, or your own `AdaptyUIRiveAddon` (e.g. on Rive version conflicts).
    @MainActor
    static func registerRiveAddon(_ addon: any AdaptyUIRiveAddon) {
        AdaptyUIAddons.rive = addon
    }
}

#endif
