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
///
/// On `contentAxes` — those where the item has no length — the deck measured the
/// content without a length, and the item's size there is the content's own
/// answer. Placement proposes no length on those axes either: proposing the answer
/// back would let content that picks its layout from the proposal place a layout
/// other than the one it was measured with.
@available(iOS 16.0, macOS 13.0, visionOS 1.0, *)
struct AdaptyUIDeckItemLayout: Layout {
    let contentAxes: Axis.Set

    func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache _: inout ()
    ) -> CGSize {
        let width = bounded(proposal.width)
        let height = bounded(proposal.height)

        // A fully bounded offer is the answer; asking the content too would only
        // measure it once more with a size it never gets placed with.
        if let width, let height { return CGSize(width: width, height: height) }

        let content = subviews.first?.sizeThatFits(proposal) ?? .zero
        return CGSize(width: width ?? content.width, height: height ?? content.height)
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
                proposal: ProposedViewSize(
                    width: contentAxes.contains(.horizontal) ? nil : bounds.width,
                    height: contentAxes.contains(.vertical) ? nil : bounds.height
                )
            )
        }
    }

    /// The default merges the children's guides, which asks every child down the
    /// tree again. Nothing in the rendering aligns to a container's guides.
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

    /// A proposal is usable as a size only when it is both present and finite.
    private func bounded(_ length: CGFloat?) -> CGFloat? {
        guard let length, length.isFinite else { return nil }
        return length
    }
}
