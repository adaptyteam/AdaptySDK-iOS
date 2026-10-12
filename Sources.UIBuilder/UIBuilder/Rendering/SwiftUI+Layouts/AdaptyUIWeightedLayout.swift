//
//  AdaptyUIWeightedLayout.swift
//  AdaptyUIBuilder
//

import SwiftUI

/// Lays out the items of a `Row` or a `Column` along one axis, each in its own
/// cell with its own alignment.
///
/// All arithmetic lives in `AdaptyUIWeightedSolver`, which is free of SwiftUI and
/// unit-tested; this type only translates between the proposal, the subviews and
/// the solver. Like `AdaptyUIDeckLayout` it solves again in `placeSubviews`
/// instead of keeping a `Cache`, so sizing and placement read the same proposal
/// through the same rule.
@available(iOS 16.0, macOS 13.0, visionOS 1.0, *)
struct AdaptyUIWeightedLayout: Layout {
    let axis: AdaptyUIWeightedSolver.Axis
    let mainAxisSizing: AdaptyUILayoutSizing
    let crossAxisSizing: AdaptyUILayoutSizing
    let spacing: CGFloat
    let items: [AdaptyUIWeightedSolver.Item]

    func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache _: inout ()
    ) -> CGSize {
        solve(proposal: proposal, subviews: subviews).size
    }

    func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache _: inout ()
    ) {
        let result = solve(proposal: proposal, subviews: subviews)

        for (index, frame) in result.frames.enumerated() {
            subviews[index].place(
                at: CGPoint(x: bounds.minX + frame.anchor.x, y: bounds.minY + frame.anchor.y),
                anchor: UnitPoint(x: items[index].anchorX, y: items[index].anchorY),
                proposal: ProposedViewSize(frame.cell.size)
            )
        }

        // Unreachable while the view builds one subview per item, but every subview
        // must be placed, so a leftover collapses instead of landing unplaced.
        for index in result.frames.count ..< subviews.count {
            subviews[index].place(
                at: CGPoint(x: bounds.minX, y: bounds.minY),
                anchor: .topLeading,
                proposal: .zero
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

    /// The view wraps every item in exactly one subview, so subview `i` is the
    /// content of item `i`. If the two ever drift apart, the pairs that do exist are
    /// laid out rather than trapping on an index.
    private func solve(proposal: ProposedViewSize, subviews: Subviews) -> AdaptyUIWeightedSolver.Result {
        AdaptyUIWeightedSolver.solve(
            axis: axis,
            mainAxisSizing: mainAxisSizing,
            crossAxisSizing: crossAxisSizing,
            spacing: spacing,
            items: Array(items.prefix(subviews.count)),
            proposedWidth: proposal.width,
            proposedHeight: proposal.height,
            measure: { index, proposedWidth, proposedHeight in
                subviews[index].sizeThatFits(
                    ProposedViewSize(width: proposedWidth, height: proposedHeight)
                )
            }
        )
    }
}
