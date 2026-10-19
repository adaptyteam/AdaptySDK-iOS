//
//  AdaptyUISwitchLayout.swift
//  AdaptyUIBuilder
//

import SwiftUI

/// Lays out a `Switch`: the chosen branch, sized by its content, and, when a
/// condition reads `available_*`, an invisible probe that learns what the parent
/// proposes.
///
/// The branch is measured and placed with the parent's proposal. The probe is
/// the first subview: it takes no part in the switch's size and is placed with
/// the proposal itself, so its frame is the length the parent offers on each
/// axis. An axis without a length — `nil`, or infinity from a probing parent —
/// reads as the screen, as the conditions do without a proposal.
@available(iOS 16.0, macOS 13.0, visionOS 1.0, *)
struct AdaptyUISwitchLayout: Layout {
    let screenSize: CGSize
    /// Whether the first subview is the probe.
    let probes: Bool

    func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache _: inout ()
    ) -> CGSize {
        branch(subviews).reduce(CGSize.zero) { size, subview in
            let next = subview.sizeThatFits(proposal)
            return CGSize(width: max(size.width, next.width), height: max(size.height, next.height))
        }
    }

    func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache _: inout ()
    ) {
        if probes, let probe = subviews.first {
            probe.place(at: bounds.origin, proposal: Self.offered(proposal, screen: screenSize))
        }
        // Views of one branch overlay each other in the middle, as in a `ZStack`.
        for subview in branch(subviews) {
            subview.place(at: CGPoint(x: bounds.midX, y: bounds.midY), anchor: .center, proposal: proposal)
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

    /// The length the parent offers on each axis; the screen where it offers none.
    static func offered(_ proposal: ProposedViewSize, screen: CGSize) -> ProposedViewSize {
        func length(_ proposed: CGFloat?, _ screen: CGFloat) -> CGFloat {
            guard let proposed, proposed.isFinite else { return screen }
            return proposed
        }
        return ProposedViewSize(
            width: length(proposal.width, screen.width),
            height: length(proposal.height, screen.height)
        )
    }

    private func branch(_ subviews: Subviews) -> Subviews.SubSequence {
        probes ? subviews.dropFirst() : subviews[...]
    }
}
