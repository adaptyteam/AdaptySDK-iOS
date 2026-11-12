//
//  AdaptyUIBoxFrameLayout.swift
//  AdaptyUIBuilder
//

import SwiftUI

/// The `min` / `max` / `fill_max` frame of a box.
///
/// Sizes like SwiftUI's `frame(minWidth:maxWidth:minHeight:maxHeight:alignment:)`,
/// but places the child with the proposal it was measured with. The native frame
/// measures the child again with its own size, and on an axis without bounds its
/// size is the child's answer, so the child got that answer back as a proposal
/// whenever the parent proposed a number on that axis. Content that picks its
/// layout from the proposal then placed a different layout than it was measured
/// with.
///
/// Per axis:
/// - the child is proposed the box's proposal clamped to the bounds, `nil` staying
///   `nil`;
/// - without bounds the box takes the child's size;
/// - with bounds the box takes the proposal clamped between `min ?? child` and
///   `max ?? child`, and without a proposal the child's size clamped the same way.
///
/// Several subviews — a custom element that renders more than one view — each get
/// this frame and overlay each other; the box is the largest of them.
@available(iOS 16.0, macOS 13.0, visionOS 1.0, *)
struct AdaptyUIBoxFrameLayout: Layout {
    var minWidth: CGFloat?
    var maxWidth: CGFloat?
    var minHeight: CGFloat?
    var maxHeight: CGFloat?
    /// Where the child sits in the box: `0` leading/top, `1` trailing/bottom.
    var alignment: UnitPoint

    func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache _: inout ()
    ) -> CGSize {
        let childProposal = childProposal(proposal)
        return subviews.reduce(CGSize.zero) { size, subview in
            let child = subview.sizeThatFits(childProposal)
            return CGSize(
                width: max(size.width, Self.length(proposal.width, child.width, minWidth, maxWidth)),
                height: max(size.height, Self.length(proposal.height, child.height, minHeight, maxHeight))
            )
        }
    }

    func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache _: inout ()
    ) {
        let measured = childProposal(proposal)
        for subview in subviews {
            let child = subview.sizeThatFits(measured)
            let placed = Self.placementProposal(box: bounds.size, child: child, measured: measured)
            let size = placed == measured ? child : subview.sizeThatFits(placed)
            subview.place(
                at: CGPoint(
                    x: bounds.minX + Self.offset(alignment.x, bounds.width - size.width),
                    y: bounds.minY + Self.offset(alignment.y, bounds.height - size.height)
                ),
                proposal: placed
            )
        }
    }

    /// The default merges the children's guides, which asks every child down the
    /// tree again. Nothing in the rendering aligns to a box's guides.
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

    private func childProposal(_ proposal: ProposedViewSize) -> ProposedViewSize {
        ProposedViewSize(
            width: proposal.width.map { Self.clamp($0, minWidth, maxWidth) },
            height: proposal.height.map { Self.clamp($0, minHeight, maxHeight) }
        )
    }

    /// Where the child starts in the free space. In an infinite box there is no
    /// place to speak of: the native frame puts the child at infinity or NaN, and a
    /// layout that did the same would crash once mirrored for right-to-left, so the
    /// child stays at the origin.
    private static func offset(_ fraction: CGFloat, _ freeSpace: CGFloat) -> CGFloat {
        let offset = fraction * freeSpace
        return offset.isFinite ? offset : 0
    }

    /// The native frame places the child with its own size, except on an axis
    /// where that size is the child's answer to no proposal at all, which stays
    /// `nil`. Where the box is the child's answer, or the proposal the child was
    /// measured with, on both axes, nothing changes for the child and it keeps the
    /// measured proposal: a number it answered, proposed back, is the echo this
    /// layout exists to avoid. Where the bounds made the box differ from both on
    /// some axis, the child is placed as natively — a `min` stretches content that
    /// takes any offer, and the other axis keeps what the child answered, which
    /// is what holds a wrapped text to the height it was measured with.
    private static func placementProposal(
        box: CGSize,
        child: CGSize,
        measured: ProposedViewSize
    ) -> ProposedViewSize {
        if (box.width == child.width || box.width == measured.width)
            && (box.height == child.height || box.height == measured.height)
        {
            return measured
        }
        return ProposedViewSize(
            width: box.width == child.width && measured.width == nil ? nil : box.width,
            height: box.height == child.height && measured.height == nil ? nil : box.height
        )
    }

    /// The box along one axis. `min` lifts the child up to it, unless the
    /// proposal is smaller still; `max` cuts the child down to it, and with a
    /// proposal takes up to the proposal. A missing proposal counts as the child.
    private static func length(_ proposed: CGFloat?, _ child: CGFloat, _ lower: CGFloat?, _ upper: CGFloat?) -> CGFloat {
        var result = child
        if let lower { result = max(lower, min(result, proposed ?? result)) }
        if let upper { result = min(upper, max(result, proposed ?? result)) }
        return result
    }

    private static func clamp(_ value: CGFloat, _ lower: CGFloat?, _ upper: CGFloat?) -> CGFloat {
        var result = value
        if let lower { result = max(result, lower) }
        if let upper { result = min(result, upper) }
        return result
    }
}
