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
        if #available(iOS 16.0, macOS 13.0, visionOS 1.0, *) {
            AdaptyUIScreenHolderLayout {
                ForEach(screens, id: \.id) { screenBuilder($0) }
            }
        } else {
            legacyBody
        }
    }

    // MARK: - iOS 15

    /// `Layout` is unavailable before iOS 16, so the screens keep sharing a `ZStack`
    /// and a screen wider than the viewport still stretches its neighbour for the
    /// duration of a transition.
    ///
    /// The alternative — anchoring the size on the current screen and rendering the
    /// rest as its background / overlay — fixes the layout but moves the outgoing
    /// screen to a different position in the view tree mid-transition. SwiftUI then
    /// hands the outgoing screen's state to the incoming one (scroll offsets, timers,
    /// players, armed transition animations) and remounts the outgoing screen, which
    /// restarts its exit animation. Keeping the screens siblings preserves identity,
    /// so the layout defect is left in place here rather than traded for a state one.
    private var legacyBody: some View {
        ZStack {
            ForEach(screens, id: \.id) { screenBuilder($0) }
        }
    }
}

/// Places every screen with the proposal the holder itself received, instead of the
/// `ZStack` behaviour of re-proposing the union of all children. The holder reports
/// the size of the last screen — the one the navigator is currently showing.
@available(iOS 16.0, macOS 13.0, visionOS 1.0, *)
struct AdaptyUIScreenHolderLayout: Layout {
    func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache _: inout ()
    ) -> CGSize {
        guard let anchor = subviews.last else { return .zero }
        return anchor.sizeThatFits(proposal)
    }

    func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache _: inout ()
    ) {
        for subview in subviews {
            subview.place(
                at: CGPoint(x: bounds.midX, y: bounds.midY),
                anchor: .center,
                proposal: proposal
            )
        }
    }
}

#endif
