//
//  AdaptyUIGreedyContentLayout.swift
//  AdaptyUIBuilder
//

#if canImport(UIKit)

import SwiftUI

/// Marks a subview as the available-size probe rather than content.
@available(iOS 16.0, macOS 13.0, *)
struct AdaptyUIAvailableSizeProbeKey: LayoutValueKey {
    static let defaultValue = false
}

/// Takes the whole offer on any axis the parent bounds, and the content's own
/// extent on an axis proposed `nil` — never reporting less than the content needs.
/// Optionally hands the offered size back to the caller through a probe subview.
///
/// This is the non-ratcheting replacement for the pair of tricks the old
/// `AdaptyUISwitchView` / `AdaptyUIFlexStackView` use: a greedy `GeometryReader`
/// (so an `available_*` condition can read the offer) floored by
/// `.frame(minWidth: contentsSize.width, minHeight: contentsSize.height)` (so the
/// reader cannot collapse to ~10pt when an axis is unbounded).
///
/// The floor is the bug: `contentsSize` is `@State` written from a measurement, so
/// it only ever grows. Narrowing the parent afterwards leaves the old, wider floor
/// in place and the content juts out — permanently, unless something else happens
/// to reset it. `AdaptyUISwitchView` resets it only when the selected case changes,
/// so a switch whose conditions read `orientation` never recovers from a resize at
/// all — nothing else ever clears the floor.
///
/// Here the same "at least the content" rule is recomputed from the current
/// proposal on every pass, so it cannot ratchet.
///
/// ## The probe
///
/// A caller that needs the offered size (only Switch, and only when some case reads
/// `available_*`) adds a `Color.clear`-style subview marked with
/// `AdaptyUIAvailableSizeProbeKey` and observes its geometry. The probe is placed
/// with the **proposal reduced to its bounded axes** — an axis proposed `nil` or
/// infinite is reported as 0.
///
/// That is deliberately not the layout's own size. Reporting the content extent on
/// an unbounded axis would feed the content's size back into the condition that
/// chooses the content, which can oscillate: a case that matches "height ≤ 200" and
/// is 300pt tall would flip the selection every pass. The old greedy reader read
/// ~10pt on such an axis and was stable for the same reason — the value did not
/// depend on the branch. Zero keeps that independence without pretending 10pt of
/// space exists.
///
/// Content is placed at the top-leading corner, which is where `GeometryReader`
/// puts it today.
@available(iOS 16.0, macOS 13.0, *)
struct AdaptyUIGreedyContentLayout: Layout {
    func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache _: inout ()
    ) -> CGSize {
        var content = CGSize.zero
        for subview in subviews where !subview[AdaptyUIAvailableSizeProbeKey.self] {
            let measured = subview.sizeThatFits(proposal)
            content.width = max(content.width, measured.width)
            content.height = max(content.height, measured.height)
        }

        return CGSize(
            width: max(bounded(proposal.width) ?? content.width, content.width),
            height: max(bounded(proposal.height) ?? content.height, content.height)
        )
    }

    func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache _: inout ()
    ) {
        let origin = CGPoint(x: bounds.minX, y: bounds.minY)
        let offered = ProposedViewSize(
            width: bounded(proposal.width) ?? 0,
            height: bounded(proposal.height) ?? 0
        )

        for subview in subviews {
            let isProbe = subview[AdaptyUIAvailableSizeProbeKey.self]
            subview.place(
                at: origin,
                anchor: .topLeading,
                proposal: isProbe ? offered : proposal
            )
        }
    }

    private func bounded(_ length: CGFloat?) -> CGFloat? {
        guard let length, length.isFinite else { return nil }
        return length
    }
}

#endif
