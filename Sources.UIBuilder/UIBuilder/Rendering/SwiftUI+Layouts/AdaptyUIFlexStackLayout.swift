//
//  AdaptyUIFlexStackLayout.swift
//  AdaptyUIBuilder
//

#if canImport(UIKit)

import SwiftUI

/// `flex_stack` as a `Layout`: picks the stack axis from the proposal the parent
/// makes, then lays the items out along it.
///
/// Unlike `Row` / `Column` / `Flex`, a `flex_stack` has no per-item weights — it
/// is a plain `HStack` / `VStack`, including `Spacer` items. So instead of
/// re-implementing stack semantics, this layout resolves the direction and then
/// **delegates** to `HStackLayout` / `VStackLayout`: spacing, alignment guides and
/// `Spacer` distribution stay exactly SwiftUI's, with nothing to diverge from.
///
/// What it replaces is the measuring round-trip in `AdaptyUIFlexStackView`: a
/// greedy `GeometryReader` feeding `@State availableSize`, floored by
/// `.frame(minWidth:minHeight:)` so it could not collapse when an axis is
/// unbounded. That floor only ever grows, which is why shrinking the parent after
/// the first layout never flipped the direction back (see the
/// a flex stack whose condition reads `available_width`). Here the direction is a
/// function of the current proposal, so both directions of resize are live.
///
/// Parity notes, mirroring what the `GeometryReader` does today:
/// - the container is greedy on any axis the parent bounds, and reports its
///   content extent on an axis proposed `nil` (where the old code needed the
///   floor);
/// - the stack itself is placed at the top-leading corner at its natural size,
///   which is where `GeometryReader` puts its content — so `h_align` / `v_align`
///   keep acting between the items, not against the whole free area.
@available(iOS 16.0, macOS 13.0, *)
struct AdaptyUIFlexStackLayout: Layout {
    struct Cache {
        /// Direction resolved from the last usable proposal. SwiftUI also probes a
        /// layout with degenerate proposals (`.unspecified`, `.infinity`) to learn
        /// how flexible it is; re-deciding the direction on those would report
        /// sizes for two different directions within one pass, so the probes reuse
        /// this instead.
        var direction: VC.Flex.Direction?
    }

    let condition: [VC.Condition]
    /// Direction used when `condition` matches; its opposite otherwise.
    let matchedDirection: VC.Flex.Direction
    let orientation: VC.Orientation
    let screenSize: CGSize
    /// Cross-axis alignment for the vertical direction, RTL already applied.
    let horizontalAlignment: SwiftUI.HorizontalAlignment
    /// Cross-axis alignment for the horizontal direction.
    let verticalAlignment: SwiftUI.VerticalAlignment
    let horizontalSpacing: CGFloat
    let verticalSpacing: CGFloat

    func makeCache(subviews: Subviews) -> Cache { Cache() }

    func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout Cache
    ) -> CGSize {
        guard !subviews.isEmpty else { return .zero }

        let layout = stackLayout(for: direction(for: proposal, cache: &cache))
        var stackCache = layout.makeCache(subviews: subviews)
        let content = layout.sizeThatFits(
            proposal: proposal,
            subviews: subviews,
            cache: &stackCache
        )

        // Greedy where the parent gave a bound, content-sized where it did not, and
        // never below the content — which is what the old `.frame(minWidth:minHeight:)`
        // floor was for, minus the ratchet (it was `@State` and only ever grew).
        return CGSize(
            width: max(bounded(proposal.width) ?? content.width, content.width),
            height: max(bounded(proposal.height) ?? content.height, content.height)
        )
    }

    func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout Cache
    ) {
        guard !subviews.isEmpty else { return }

        // Resolved from the same proposal `sizeThatFits` saw, not from `bounds`.
        // Deciding from the granted bounds instead looks more authoritative, but
        // the bounds are derived from the size we already reported: the two calls
        // could then pick different directions within one pass, reporting a row's
        // height and then placing a column into it.
        let layout = stackLayout(for: direction(for: proposal, cache: &cache))

        var stackCache = layout.makeCache(subviews: subviews)
        // The proposal is passed through untouched, so an axis the parent left
        // unbounded stays unbounded and the items report their natural extent —
        // the same measurement the size above was built from.
        let content = layout.sizeThatFits(
            proposal: proposal,
            subviews: subviews,
            cache: &stackCache
        )

        layout.placeSubviews(
            in: CGRect(origin: bounds.origin, size: content),
            proposal: proposal,
            subviews: subviews,
            cache: &stackCache
        )
    }

    // MARK: - Resolving the axis

    private func stackLayout(for direction: VC.Flex.Direction) -> AnyLayout {
        switch direction {
        case .horizontal:
            AnyLayout(
                HStackLayout(
                    alignment: verticalAlignment,
                    spacing: horizontalSpacing
                )
            )
        case .vertical:
            AnyLayout(
                VStackLayout(
                    alignment: horizontalAlignment,
                    spacing: verticalSpacing
                )
            )
        }
    }

    private func direction(
        for proposal: ProposedViewSize,
        cache: inout Cache
    ) -> VC.Flex.Direction {
        let available = VC.Condition.availableSize(for: condition, proposal: proposal)
        let resolved = VC.Flex.Direction.resolve(
            conditions: condition,
            matched: matchedDirection,
            available: available,
            screen: screenSize,
            orientation: orientation,
            lastResolved: cache.direction
        )
        // Only a decidable pass may seed the cache; a probe must not overwrite what
        // the last real proposal produced.
        if available != nil { cache.direction = resolved }
        return resolved
    }

    private func bounded(_ length: CGFloat?) -> CGFloat? {
        guard let length, length.isFinite else { return nil }
        return length
    }
}

#endif
