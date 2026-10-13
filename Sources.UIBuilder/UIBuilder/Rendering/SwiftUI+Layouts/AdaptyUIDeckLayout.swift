//
//  AdaptyUIDeckLayout.swift
//  AdaptyUIBuilder
//

import SwiftUI

/// Lays out the children of a `Deck` in one shared area, each with its own size
/// and alignment.
///
/// All arithmetic lives in `AdaptyUIDeckSolver`, which is free of SwiftUI and
/// unit-tested; this type only translates between the proposal, the subviews and
/// the solver. It deliberately solves again in `placeSubviews` instead of keeping
/// a `Cache`: the proposal there can differ from the one sizing saw, and a cache
/// is only worth its invalidation rules if profiling asks for it.
@available(iOS 16.0, macOS 13.0, visionOS 1.0, *)
struct AdaptyUIDeckLayout: Layout {
    let width: AdaptyUILayoutSizing
    let height: AdaptyUILayoutSizing
    let items: [AdaptyUIDeckSolver.Item]

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
                at: CGPoint(x: bounds.minX + frame.minX, y: bounds.minY + frame.minY),
                anchor: .topLeading,
                proposal: ProposedViewSize(frame.size)
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

    /// The view builds subviews by iterating the same array, so subview `i` is the
    /// content of item `i`. If the two ever drift apart, the pairs that do exist are
    /// laid out rather than trapping on an index.
    private func solve(proposal: ProposedViewSize, subviews: Subviews) -> AdaptyUIDeckSolver.Result {
        let count = min(items.count, subviews.count)

        return AdaptyUIDeckSolver.solve(
            width: width,
            height: height,
            items: Array(items.prefix(count)),
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
