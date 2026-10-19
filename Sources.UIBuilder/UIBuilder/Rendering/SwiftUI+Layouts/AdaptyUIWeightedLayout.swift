//
//  AdaptyUIWeightedLayout.swift
//  AdaptyUIBuilder
//

import SwiftUI

/// The item a subview of `AdaptyUIWeightedLayout` was built for.
@available(iOS 16.0, macOS 13.0, visionOS 1.0, *)
struct AdaptyUIWeightedItemKey: LayoutValueKey {
    static let defaultValue: Int? = nil
}

/// Lays out the items of a `Row` or a `Column` along one axis, each in its own
/// cell with its own alignment.
///
/// All arithmetic lives in `AdaptyUIWeightedSolver`, which is free of SwiftUI and
/// unit-tested; this type only translates between the proposal, the subviews and
/// the solver. Like `AdaptyUIDeckLayout` it solves again in `placeSubviews`
/// instead of keeping a `Cache`, so sizing and placement read the same proposal
/// through the same rule.
///
/// Subviews are matched to items by `AdaptyUIWeightedItemKey` rather than by
/// position, so an element is laid out exactly as it renders: one that renders
/// nothing takes no cell, and one that renders several views keeps them in one.
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
        solve(proposal: proposal, subviews: subviews).result.size
    }

    func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache _: inout ()
    ) {
        let (rendered, result) = solve(proposal: proposal, subviews: subviews)
        var placed = Set<Int>()

        // What children were measured with across the axis; a hugging cross axis
        // measures them without a length.
        let measuredCross = crossAxisSizing == .hug ? nil : (axis == .horizontal ? proposal.height : proposal.width)

        for (item, frame) in zip(rendered, result.frames) {
            var cell = ProposedViewSize(frame.cell.size)
            if items[item.item].placesAsMeasured {
                if axis == .horizontal { cell.height = measuredCross } else { cell.width = measuredCross }
            }
            // Views of one item overlay each other at the item's anchor.
            for index in item.subviews {
                subviews[index].place(
                    at: CGPoint(x: bounds.minX + frame.anchor.x, y: bounds.minY + frame.anchor.y),
                    anchor: UnitPoint(x: items[item.item].anchorX, y: items[item.item].anchorY),
                    proposal: cell
                )
                placed.insert(index)
            }
        }

        // Unreachable while the view marks every subview with its item, but every
        // subview must be placed, so a stray one collapses instead of landing
        // unplaced.
        for index in subviews.indices where !placed.contains(index) {
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

    private func solve(
        proposal: ProposedViewSize,
        subviews: Subviews
    ) -> (rendered: [AdaptyUIWeightedSolver.Rendered], result: AdaptyUIWeightedSolver.Result) {
        let rendered = AdaptyUIWeightedSolver.rendered(
            itemCount: items.count,
            subviewItems: subviews.map { $0[AdaptyUIWeightedItemKey.self] }
        )

        let result = AdaptyUIWeightedSolver.solve(
            axis: axis,
            mainAxisSizing: mainAxisSizing,
            crossAxisSizing: crossAxisSizing,
            spacing: spacing,
            items: rendered.map { items[$0.item] },
            proposedWidth: proposal.width,
            proposedHeight: proposal.height,
            measure: { index, proposedWidth, proposedHeight in
                let proposal = ProposedViewSize(width: proposedWidth, height: proposedHeight)
                return rendered[index].subviews.reduce(CGSize.zero) { size, subview in
                    let next = subviews[subview].sizeThatFits(proposal)
                    return CGSize(width: max(size.width, next.width), height: max(size.height, next.height))
                }
            }
        )

        return (rendered, result)
    }
}
