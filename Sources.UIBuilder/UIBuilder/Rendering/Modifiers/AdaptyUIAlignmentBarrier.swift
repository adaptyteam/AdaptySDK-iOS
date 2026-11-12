//
//  AdaptyUIAlignmentBarrier.swift
//  AdaptyUIBuilder
//
//  Created by Aleksey Goncharov on 07.10.2026.
//

#if canImport(UIKit)

import SwiftUI

extension View {
    /// Stops explicit alignment queries from travelling below this view on iOS 17.
    ///
    /// Inside a `ScrollView`, iOS 17 resolves an explicit alignment query again through
    /// every nested stack and `.frame(..., alignment:)`, so a layout pass costs about three
    /// times more with each level of nesting: a screen fourteen levels deep takes seconds
    /// and holds the main thread all that time. iOS 16 and iOS 18+ are not affected.
    ///
    /// UIBuilder defines no custom alignment guides and never aligns by text baseline, so
    /// every explicit alignment below this view resolves to `nil` anyway. Answering `nil`
    /// here leaves the layout as it was and only cuts the query short.
    func alignmentBarrier() -> some View {
        modifier(AdaptyUIAlignmentBarrierModifier())
    }

    /// Places this view in the size it measured, whatever frame its parent hands it.
    ///
    /// A geometry effect — `rotationEffect`, `scaleEffect`, `visualEffect` and the rest,
    /// even at their identity values — rounds the frame of its content to whole pixels,
    /// edge by edge. Where the content starts on half a pixel, as a row of a whole width
    /// centred in an odd one does at @3x, the frame comes out a pixel narrower than the
    /// content measured, and a text placed in it truncates. Placing the content with the
    /// proposal it was measured with gives it its own size back; the effect still draws
    /// it where it was.
    func measuredPlacement() -> some View {
        modifier(AdaptyUIMeasuredPlacementModifier())
    }
}

private struct AdaptyUIMeasuredPlacementModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 16.0, macOS 13.0, visionOS 1.0, *) {
            AdaptyUIAlignmentBarrierLayout { content }
        } else {
            content
        }
    }
}

private struct AdaptyUIAlignmentBarrierModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 18.0, macOS 15.0, visionOS 2.0, *) {
            content
        } else if #available(iOS 17.0, macOS 14.0, visionOS 1.0, *) {
            AdaptyUIAlignmentBarrierLayout { content }
        } else {
            content
        }
    }
}

/// Sizes its only subview as the parent would have, places it with the proposal it was
/// measured with, and reports no explicit alignment guides of its own.
@available(iOS 16.0, macOS 13.0, visionOS 1.0, *)
private struct AdaptyUIAlignmentBarrierLayout: Layout {
    func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache _: inout ()
    ) -> CGSize {
        subviews.first?.sizeThatFits(proposal) ?? .zero
    }

    func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache _: inout ()
    ) {
        subviews.first?.place(
            at: bounds.origin,
            anchor: .topLeading,
            proposal: proposal
        )
    }

    func explicitAlignment(
        of _: HorizontalAlignment,
        in _: CGRect,
        proposal _: ProposedViewSize,
        subviews _: Subviews,
        cache _: inout ()
    ) -> CGFloat? {
        nil
    }

    func explicitAlignment(
        of _: VerticalAlignment,
        in _: CGRect,
        proposal _: ProposedViewSize,
        subviews _: Subviews,
        cache _: inout ()
    ) -> CGFloat? {
        nil
    }
}

#endif
