//
//  AdaptyUIFlexLayout.swift
//  AdaptyUIBuilder
//

import SwiftUI

/// Lays out the items of a `Flex` as a row or as a column, chosen from the
/// proposal of the same layout pass.
///
/// `AdaptyUIFlexDirectionSolver` picks the direction and the weighted layout of
/// that direction does the rest, so a flex lays out exactly as the row or the
/// column it turns into. The two take the same subviews, matched to items by
/// `AdaptyUIWeightedItemKey`, and keep their identity when the direction changes.
/// Nothing is cached between calls.
@available(iOS 16.0, macOS 13.0, visionOS 1.0, *)
struct AdaptyUIFlexLayout: Layout {
    let conditions: [VC.Condition]
    let direction: VC.Flex.Direction
    let screenSize: CGSize
    let orientation: VC.Orientation
    /// The axes a box with `shrink` hugs the flex on.
    let huggedAxes: Axis.Set
    let row: AdaptyUIWeightedLayout
    let column: AdaptyUIWeightedLayout

    func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) -> CGSize {
        layout(for: proposal, subviews: subviews).sizeThatFits(proposal: proposal, subviews: subviews, cache: &cache)
    }

    func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) {
        layout(for: proposal, subviews: subviews).placeSubviews(in: bounds, proposal: proposal, subviews: subviews, cache: &cache)
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

    private func layout(for proposal: ProposedViewSize, subviews: Subviews) -> AdaptyUIWeightedLayout {
        let chosen = AdaptyUIFlexDirectionSolver.direction(
            conditions: conditions,
            direction: direction,
            proposedWidth: proposal.width,
            proposedHeight: proposal.height,
            hugsWidth: huggedAxes.contains(.horizontal),
            hugsHeight: huggedAxes.contains(.vertical),
            screen: screenSize,
            orientation: orientation,
            naturalSize: {
                var cache: Void = ()
                return (direction == .horizontal ? row : column)
                    .sizeThatFits(proposal: proposal, subviews: subviews, cache: &cache)
            }
        )
        return chosen == .horizontal ? row : column
    }
}
