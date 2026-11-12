//
//  AdaptyUIFlexStackSolver.swift
//  AdaptyUIBuilder
//

import Foundation

/// Layout arithmetic of `FlexStack` along the direction already chosen.
///
/// It reproduces the native `HStack` / `VStack` distribution, because the
/// container replaces those stacks and its children must not notice:
///
/// - the main-axis proposal minus spacing is shared out group by group in
///   descending priority; every lower group is reserved its minimum first;
/// - inside a group children are offered an equal share of what is left, the
///   least flexible (`size(∞) - size(0)`) first; among unbounded ones the larger
///   minimum first, any other tie in the children's order;
/// - `space` is the lowest group, as a `Spacer` is in a native stack: it gets only
///   what the other children leave, and never less than its minimum;
/// - an unspecified main axis gives every child its ideal length;
/// - children are placed with the stack's cross proposal, or with its own cross
///   length when the proposal has none — and then the main axis is shared out
///   again with that cross length, as a native stack does;
/// - `space` takes no room on the cross axis.
///
/// Free of SwiftUI so it runs under a plain `swift test`.
enum AdaptyUIFlexStackSolver {
    enum Axis: Sendable, Equatable {
        case horizontal
        case vertical
    }

    struct Child: Sendable, Equatable {
        let isSpace: Bool
        let priority: Double
    }

    /// `offer` is the proposal the child was sized with and must be placed with:
    /// `main` along the stack, `cross` the stack's own cross proposal.
    struct Frame: Sendable, Equatable {
        let origin: CGPoint
        let size: CGSize
        let offerWidth: CGFloat?
        let offerHeight: CGFloat?
    }

    struct Result: Sendable, Equatable {
        let size: CGSize
        let frames: [Frame]
    }

    /// - Parameters:
    ///   - crossAnchor: `0` top/leading, `0.5` center, `1` bottom/trailing.
    ///   - measure: size of child `index` for a proposal `(width, height)`.
    static func solve(
        axis: Axis,
        spacing: CGFloat,
        crossAnchor: CGFloat,
        children: [Child],
        proposedWidth: CGFloat?,
        proposedHeight: CGFloat?,
        measure: (_ index: Int, _ width: CGFloat?, _ height: CGFloat?) -> CGSize
    ) -> Result {
        guard !children.isEmpty else { return Result(size: .zero, frames: []) }

        let proposedMain = axis == .horizontal ? proposedWidth : proposedHeight
        let proposedCross = axis == .horizontal ? proposedHeight : proposedWidth

        func size(_ index: Int, _ main: CGFloat?, cross: CGFloat?) -> (main: CGFloat, cross: CGFloat) {
            let s = axis == .horizontal
                ? measure(index, main, cross)
                : measure(index, cross, main)
            return axis == .horizontal ? (s.width, s.height) : (s.height, s.width)
        }

        let totalSpacing = spacing * CGFloat(children.count - 1)

        /// Shares the main axis out among the children measured with `cross`.
        func distribute(cross: CGFloat?) -> (offers: [CGFloat?], sizes: [(main: CGFloat, cross: CGFloat)]) {
            var offers = [CGFloat?](repeating: nil, count: children.count)
            var sizes = [(main: CGFloat, cross: CGFloat)](repeating: (0, 0), count: children.count)

            guard let proposedMain else {
                for index in children.indices {
                    sizes[index] = size(index, nil, cross: cross)
                }
                return (offers, sizes)
            }

            let minimums = children.indices.map { size($0, 0, cross: cross).main }
            let flexibility = children.indices.map { size($0, .infinity, cross: cross).main - minimums[$0] }

            func rank(_ child: Child) -> Double { child.isSpace ? -.infinity : child.priority }
            let groups = Dictionary(grouping: children.indices, by: { rank(children[$0]) })
                .sorted { $0.key > $1.key }

            var remaining = proposedMain - totalSpacing
            for (position, group) in groups.enumerated() {
                let reserved = groups[(position + 1)...].reduce(0) { sum, lower in
                    sum + lower.value.reduce(0) { $0 + minimums[$1] }
                }
                var available = remaining - reserved
                var left = group.value.count

                // Least flexible first. Two unbounded children tie at infinity, and
                // the larger minimum goes first, as if `∞ - minimum` were compared
                // exactly; any other tie keeps the children's order.
                let order = group.value.sorted {
                    let lhs = flexibility[$0], rhs = flexibility[$1]
                    if lhs != rhs { return lhs < rhs }
                    if lhs.isInfinite, minimums[$0] != minimums[$1] { return minimums[$0] > minimums[$1] }
                    return $0 < $1
                }
                for index in order {
                    let offer = max(0, available / CGFloat(left))
                    offers[index] = offer
                    sizes[index] = size(index, offer, cross: cross)
                    if available.isFinite { available -= sizes[index].main }
                    if remaining.isFinite { remaining -= sizes[index].main }
                    left -= 1
                }
            }
            return (offers, sizes)
        }

        let sized = distribute(cross: proposedCross)
        let mainLength = sized.sizes.reduce(0) { $0 + $1.main } + totalSpacing
        let crossLength = children.indices
            .filter { !children[$0].isSpace }
            .map { sized.sizes[$0].cross }
            .max() ?? 0

        // Children are placed with the stack's cross proposal, or with the stack's own
        // cross length when there is none, so flexible children span the stack. In
        // that case a native stack shares the main axis out again with that cross
        // length and lines the children up by the result, not by the shares it sized
        // itself with: content that keeps an aspect ratio changes its flexibility
        // and its length, and can push its neighbours past the stack's own length.
        let placementCross = proposedCross ?? crossLength
        let placed = proposedCross == nil ? distribute(cross: placementCross) : sized
        // Children are aligned in the cross length of the shares they are placed
        // with, which is not the stack's own length when the shares changed.
        let alignedCross = children.indices
            .filter { !children[$0].isSpace }
            .map { placed.sizes[$0].cross }
            .max() ?? 0

        var position: CGFloat = 0
        let frames = children.indices.map { index in
            let main = placed.sizes[index].main
            let cross = children[index].isSpace ? 0 : placed.sizes[index].cross
            // An infinite stack has no place for its children to speak of; NaN or
            // infinity would crash a layout once mirrored for right-to-left.
            let crossOffset = Self.finite((alignedCross - cross) * crossAnchor)
            let mainOffset = Self.finite(position)
            defer { position += main + spacing }

            return axis == .horizontal
                ? Frame(
                    origin: CGPoint(x: mainOffset, y: crossOffset),
                    size: CGSize(width: main, height: cross),
                    offerWidth: placed.offers[index],
                    offerHeight: placementCross
                )
                : Frame(
                    origin: CGPoint(x: crossOffset, y: mainOffset),
                    size: CGSize(width: cross, height: main),
                    offerWidth: placementCross,
                    offerHeight: placed.offers[index]
                )
        }

        return Result(
            size: axis == .horizontal
                ? CGSize(width: mainLength, height: crossLength)
                : CGSize(width: crossLength, height: mainLength),
            frames: frames
        )
    }

    private static func finite(_ value: CGFloat) -> CGFloat {
        value.isFinite ? value : 0
    }
}
