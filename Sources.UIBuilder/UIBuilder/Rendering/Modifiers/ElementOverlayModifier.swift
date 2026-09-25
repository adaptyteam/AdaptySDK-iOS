//
//  ElementOverlayModifier.swift
//
//
//  Created by Aleksey Goncharov on 19.03.2026.
//

#if canImport(UIKit)

import SwiftUI

struct AdaptyUIOverlayElementsView<ScreenHolderContent: View>: View {
    var overlays: [VC.AlignedElement]
    var screenHolderBuilder: () -> ScreenHolderContent

    @Environment(\.layoutDirection)
    private var layoutDirection: LayoutDirection

    var body: some View {
        ForEach(overlays.indices, id: \.self) { index in
            let item = overlays[index]
            // A flexible frame never shrinks below its child, so an oversized layer
            // made the frame as wide as itself and the alignment inside it became a
            // no-op — every h_align collapsed to the centering done by the enclosing
            // layer. Stretch an inert placeholder instead and let the overlay's own
            // alignment place the layer, which keeps overflow on the expected side.
            Color.clear
                .allowsHitTesting(false)
                .overlay(alignment: .from(
                    horizontal: item.horizontalAlignment.swiftuiValue(with: layoutDirection),
                    vertical: item.verticalAlignment.swiftuiValue
                )) {
                    AdaptyUIElementView(
                        item.content,
                        screenHolderBuilder: screenHolderBuilder
                    )
                }
        }
    }
}

struct ElementOverlayModifier<ScreenHolderContent: View>: ViewModifier {
    var overlays: [VC.AlignedElement]?
    var screenHolderBuilder: () -> ScreenHolderContent

    func body(content: Content) -> some View {
        if let overlays, !overlays.isEmpty {
            content
                .overlay {
                    AdaptyUIOverlayElementsView(
                        overlays: overlays,
                        screenHolderBuilder: screenHolderBuilder
                    )
                }
        } else {
            content
        }
    }
}

#endif
