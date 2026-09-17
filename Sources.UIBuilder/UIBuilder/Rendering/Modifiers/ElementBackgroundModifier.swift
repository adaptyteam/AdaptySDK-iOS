//
//  ElementBackgroundModifier.swift
//
//
//  Created by Aleksey Goncharov on 2026-03-23.
//

#if canImport(UIKit)

import SwiftUI

struct AdaptyUIBackgroundElementsView<ScreenHolderContent: View>: View {
    var backgrounds: [VC.AlignedElement]
    var screenHolderBuilder: () -> ScreenHolderContent

    @Environment(\.layoutDirection)
    private var layoutDirection: LayoutDirection

    var body: some View {
        ForEach(backgrounds.indices, id: \.self) { index in
            let item = backgrounds[index]
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

struct ElementBackgroundModifier<ScreenHolderContent: View>: ViewModifier {
    var backgrounds: [VC.AlignedElement]?
    var screenHolderBuilder: () -> ScreenHolderContent

    func body(content: Content) -> some View {
        if let backgrounds, !backgrounds.isEmpty {
            content
                .background {
                    AdaptyUIBackgroundElementsView(
                        backgrounds: backgrounds,
                        screenHolderBuilder: screenHolderBuilder
                    )
                }
        } else {
            content
        }
    }
}

#endif
