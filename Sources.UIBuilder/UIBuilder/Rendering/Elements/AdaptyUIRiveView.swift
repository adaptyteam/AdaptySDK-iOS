//
//  AdaptyUIRiveView.swift
//  AdaptyUIBuilder
//
//  PoC: renders the `rive` element via the injected addon, or falls back
//  (Color.clear + debug warning) when no addon is registered. The load-failure
//  fallback (bad animation_id / artboard / state machine) lives in the addon,
//  which owns the async load.
//

#if canImport(UIKit)

import SwiftUI

@MainActor
struct AdaptyUIRiveView: View {
    private let rive: VC.Rive

    init(_ rive: VC.Rive) {
        self.rive = rive
    }

    var body: some View {
        if let addon = AdaptyUIAddons.rive {
            addon.makeView(context: .init(
                animationId: rive.animationId,
                artboard: rive.artboard,
                stateMachine: rive.stateMachine,
                fit: rive.fit,
                autoplay: rive.autoplay,
                values: rive.values,
                triggers: rive.triggers
            ))
        } else {
            Color.clear
                .onAppear {
                    #if DEBUG
                    Log.ui.error("AdaptyUIRiveView: Rive addon not registered; element '\(rive.animationId)' skipped")
                    #endif
                }
        }
    }
}

#endif
