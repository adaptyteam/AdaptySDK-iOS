//
//  AdaptyUIScreenHolderView.swift
//  AdaptyUIBuilder
//
//  Created by Alex Goncharov on 07/08/2026.
//

#if canImport(UIKit)

import SwiftUI

/// Renders the screens of a navigator in the place of its `screen_holder`.
///
/// While a transition is running, the outgoing and the incoming screen live in the
/// holder at the same time. A plain `ZStack` would size itself to the union of the
/// two and then re-propose that union to every child, so a screen whose content is
/// wider than the viewport stretches the *other* screen for the duration of the
/// animation, and the layout snaps back as soon as the outgoing screen is dropped.
///
/// Every screen has to be laid out exactly as if it were alone in the holder, while
/// the holder itself keeps hugging its screen — a pop-over or bottom-sheet navigator
/// derives its size from the screen it shows. The current (last) screen is therefore
/// the sizing anchor, and the others are laid out with the holder's own proposal
/// without contributing to its size.
///
/// The screens stay siblings of one container so that their identity — and with it
/// their state and their running transition animations — survives a screen change.
@available(iOS 16.0, macOS 13.0, visionOS 1.0, *)
struct AdaptyUIScreenHolderView<ScreenContent: View>: View {
    private let screens: [AdaptyUIScreenViewModel]
    private let screenBuilder: (AdaptyUIScreenViewModel) -> ScreenContent

    init(
        screens: [AdaptyUIScreenViewModel],
        @ViewBuilder screenBuilder: @escaping (AdaptyUIScreenViewModel) -> ScreenContent
    ) {
        self.screens = screens
        self.screenBuilder = screenBuilder
    }

    var body: some View {
        AdaptyUIScreenHolderLayout {
            ForEach(screens, id: \.id) { screenBuilder($0) }
        }
    }
}

#endif
