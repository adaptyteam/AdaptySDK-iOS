//
//  AdaptyUIWeightedSolver.swift
//  AdaptyUIBuilder
//

import Foundation

/// Layout arithmetic of `Row` and `Column`: one rule for both, with the main axis
/// as a parameter.
///
/// Deliberately free of SwiftUI and of `#if canImport(UIKit)`, like
/// `AdaptyUIDeckSolver`: the weight rules are then covered by unit tests that run
/// on a plain `swift test`. `AdaptyUIWeightedLayout` is the SwiftUI side of this.
enum AdaptyUIWeightedSolver {
    enum Axis: Equatable {
        /// `Row`: items follow each other horizontally.
        case horizontal
        /// `Column`: items follow each other vertically.
        case vertical
    }

    /// A `GridItem` length along the main axis with its unit already resolved to
    /// points, so the arithmetic below needs neither the environment nor the
    /// layout direction.
    enum Length: Equatable {
        case points(CGFloat)
        case weight(Int)
    }

    /// One item as the layout sees it. Anchors are fractions of the item's cell —
    /// `0` leading/top, `0.5` center, `1` trailing/bottom — already mapped for the
    /// current layout direction.
    struct Item: Equatable {
        let length: Length
        let anchorX: CGFloat
        let anchorY: CGFloat
    }

    /// Where one item goes: its cell, and the point inside the cell where the
    /// child's own anchor lands. The child is proposed the whole cell, so content
    /// that takes the offer fills it and content with a size of its own sits at
    /// the anchor, overflowing the cell around it when it is larger.
    struct Frame: Equatable {
        let cell: CGRect
        let anchor: CGPoint
    }

    /// The container's size plus one frame per item, in the container's own
    /// coordinate space with the origin at its top-leading corner.
    struct Result: Equatable {
        let size: CGSize
        let frames: [Frame]
    }

    /// Resolves the container and its items.
    ///
    /// Main axis:
    /// - a `points` item gets its length;
    /// - with a main-axis proposal, weighted items share what is left after the
    ///   fixed items and the spacing, never less than zero;
    /// - a row without a width shares the narrowest length in which every
    ///   weighted item fits its content: one unit per weight, the unit being the
    ///   largest natural width per weight. The row reports exactly the width
    ///   that, proposed back, splits into the same cells;
    /// - a column without a height gives weighted items height 0;
    /// - in `hug` mode a weighted item gets length 0.
    ///
    /// Both axes size the container by the same rule: `fill` takes the proposal
    /// and falls back to the content without one, `hug` takes the content. The
    /// main-axis content is the item lengths plus the spacing, the cross-axis
    /// content is the largest child.
    ///
    /// On a filling cross axis children are measured with the container's cross
    /// proposal, `nil` included. On a hugging one they are measured with `nil`
    /// whatever the proposal, so a child that takes any offer — a box with
    /// `fill_max` — stretches to the result when placed instead of setting it.
    /// Placement proposes every child its whole cell either way.
    ///
    /// Zero and infinite proposals go through the same rules: a `fill` axis
    /// proposed infinity reports infinity, as the greedy stacks it replaces did.
    ///
    /// `measure` reports the size of child `index` for a proposal where `nil` on
    /// an axis asks for the child's own extent along it.
    static func solve(
        axis: Axis,
        mainAxisSizing: AdaptyUILayoutSizing,
        crossAxisSizing: AdaptyUILayoutSizing,
        spacing: CGFloat,
        items: [Item],
        proposedWidth: CGFloat?,
        proposedHeight: CGFloat?,
        measure: (_ index: Int, _ proposedWidth: CGFloat?, _ proposedHeight: CGFloat?) -> CGSize
    ) -> Result {
        let proposedMain = axis == .horizontal ? proposedWidth : proposedHeight
        let proposedCross = axis == .horizontal ? proposedHeight : proposedWidth

        func measureAlongAxis(_ index: Int, main: CGFloat?, cross: CGFloat?) -> (main: CGFloat, cross: CGFloat) {
            switch axis {
            case .horizontal:
                let size = measure(index, main, cross)
                return (max(0, size.width), max(0, size.height))
            case .vertical:
                let size = measure(index, cross, main)
                return (max(0, size.height), max(0, size.width))
            }
        }

        let gaps = CGFloat(max(0, items.count - 1))
        var totalWeight = 0
        var reserved: CGFloat = 0
        for item in items {
            switch item.length {
            case let .points(value): reserved += max(0, value)
            case let .weight(value): totalWeight += max(0, value)
            }
        }
        // A negative spacing overlaps neighbours but does not hand the overlap to
        // the weighted items, as with the stacks this layout replaces.
        reserved += max(0, spacing) * gaps

        let crossProposal = crossAxisSizing == .hug ? nil : proposedCross

        /// The main-axis length the weighted items share, or nil when they get none.
        func weightedShare() -> CGFloat? {
            guard mainAxisSizing == .fill, totalWeight > 0 else { return nil }
            if let proposedMain { return max(0, proposedMain - reserved) }
            guard axis == .horizontal else { return nil }

            let unit = items.indices.compactMap { index -> CGFloat? in
                guard case let .weight(weight) = items[index].length, weight > 0 else { return nil }
                return measureAlongAxis(index, main: nil, cross: crossProposal).main / CGFloat(weight)
            }.max() ?? 0
            return unit * CGFloat(totalWeight)
        }

        let share = weightedShare()

        let lengths: [CGFloat] = items.map { item in
            switch item.length {
            case let .points(value):
                max(0, value)
            case let .weight(weight):
                if let share, weight > 0 { share * CGFloat(weight) / CGFloat(totalWeight) } else { 0 }
            }
        }

        let contentMain = max(0, lengths.reduce(0, +) + spacing * gaps)
        let main: CGFloat =
            switch mainAxisSizing {
            case .hug: contentMain
            // Without a proposal the weighted share is reported together with what
            // was reserved for it, so the same width proposed back yields the same
            // share. A negative spacing then reports more than the items take up,
            // as it does with a proposal.
            case .fill: proposedMain.map { max(0, $0) } ?? share.map { reserved + $0 } ?? contentMain
            }

        /// Measured only when the result needs it: a filling axis with a proposal
        /// takes the proposal without asking the children.
        func contentCross() -> CGFloat {
            items.indices.map { index in
                measureAlongAxis(index, main: lengths[index], cross: crossProposal).cross
            }.max() ?? 0
        }

        let cross: CGFloat =
            switch crossAxisSizing {
            case .hug: contentCross()
            case .fill: proposedCross.map { max(0, $0) } ?? contentCross()
            }

        var cursor: CGFloat = 0
        let frames = items.indices.map { index in
            let cell =
                switch axis {
                case .horizontal: CGRect(x: cursor, y: 0, width: lengths[index], height: cross)
                case .vertical: CGRect(x: 0, y: cursor, width: cross, height: lengths[index])
                }
            cursor += lengths[index] + spacing

            return Frame(
                cell: cell,
                anchor: CGPoint(
                    x: cell.minX + items[index].anchorX * cell.width,
                    y: cell.minY + items[index].anchorY * cell.height
                )
            )
        }

        return Result(
            size: axis == .horizontal ? CGSize(width: main, height: cross) : CGSize(width: cross, height: main),
            frames: frames
        )
    }
}
