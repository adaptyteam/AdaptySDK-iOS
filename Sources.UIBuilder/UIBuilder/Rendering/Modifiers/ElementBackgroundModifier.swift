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
