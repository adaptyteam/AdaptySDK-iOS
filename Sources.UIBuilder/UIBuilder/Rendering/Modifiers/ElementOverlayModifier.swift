//
//  ElementOverlayModifier.swift
//
//
//  Created by Aleksey Goncharov on 19.03.2026.
//

#if canImport(UIKit)

import SwiftUI

struct AdaptyUIOverlayElementsView<ScreenHolderContent: View>: View {
    var overlays: [VC.Element.Overlay]
    var screenHolderBuilder: () -> ScreenHolderContent

    @Environment(\.layoutDirection)
    private var layoutDirection: LayoutDirection

    var body: some View {
        ForEach(overlays.indices, id: \.self) { index in
            let item = overlays[index]
            AdaptyUIElementView(
                item.content,
                screenHolderBuilder: screenHolderBuilder
            )
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity,
                alignment: .from(
                    horizontal: item.horizontalAlignment.swiftuiValue(with: layoutDirection),
                    vertical: item.verticalAlignment.swiftuiValue
                )
            )
        }
    }
}

struct ElementOverlayModifier<ScreenHolderContent: View>: ViewModifier {
    var overlays: [VC.Element.Overlay]?
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
