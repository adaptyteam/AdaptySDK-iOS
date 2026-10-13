//
//  AdaptyUIDeckItemLayout.swift
//  AdaptyUIBuilder
//

import SwiftUI

/// Gives one `DeckItem` the size the deck resolved for it.
///
/// `Layout.place(at:anchor:proposal:)` only *proposes* a size, and a child that
/// sizes itself by its content — a `box` without lengths, an image, a short text —
/// ignores that proposal. The contract is stricter: a child with `width` or
/// `height` takes exactly that size, so `{ "parent": 1 }` fills the deck and
/// `{ "parent": 1.5 }` overflows it.
///
/// This wrapper closes the gap. On an axis with a finite proposal it reports the
/// whole offer, so the item occupies its resolved size whatever the content wants;
/// on an axis proposed `nil` it reports the content's own extent, which is what
/// keeps the deck's measurement of `content` children honest. The content itself is
/// proposed the resulting size, so flexible content fills it and text wraps inside
/// it, while content with a size of its own keeps that size and is centered.
@available(iOS 16.0, macOS 13.0, visionOS 1.0, *)
struct AdaptyUIDeckItemLayout: Layout {
    func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache _: inout ()
    ) -> CGSize {
        let content = subviews.first?.sizeThatFits(proposal) ?? .zero

        return CGSize(
            width: bounded(proposal.width) ?? content.width,
            height: bounded(proposal.height) ?? content.height
        )
    }

    func placeSubviews(
        in bounds: CGRect,
        proposal _: ProposedViewSize,
        subviews: Subviews,
        cache _: inout ()
    ) {
        for subview in subviews {
            subview.place(
                at: CGPoint(x: bounds.midX, y: bounds.midY),
                anchor: .center,
                proposal: ProposedViewSize(bounds.size)
            )
        }
    }

    /// A proposal is usable as a size only when it is both present and finite.
    private func bounded(_ length: CGFloat?) -> CGFloat? {
        guard let length, length.isFinite else { return nil }
        return length
    }
}
