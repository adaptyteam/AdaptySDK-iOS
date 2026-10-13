//
//  AdaptyUIScreenHolderLayout.swift
//  AdaptyUIBuilder
//
//  Created by Alex Goncharov on 07/08/2026.
//

#if canImport(UIKit)

import SwiftUI

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
