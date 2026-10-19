//
//  AdaptyUIFlexStackLayout.swift
//  AdaptyUIBuilder
//

import SwiftUI

/// Marks the `Spacer` of a `space` item, so the layout can tell it apart from
/// content without relying on subview indices.
@available(iOS 16.0, macOS 13.0, visionOS 1.0, *)
struct AdaptyUIFlexStackSpaceKey: LayoutValueKey {
    static let defaultValue = false
}

/// Lays out the children of a `FlexStack` in a row or a column, chosen from the
/// proposal of the same layout pass.
///
/// `AdaptyUIFlexDirectionSolver` picks the direction and `AdaptyUIFlexStackSolver`
/// lays the children out the way a native `HStack` / `VStack` would; this type
/// only translates between the proposal, the subviews and the solvers. Nothing is
/// cached between calls, so sizing and placement each choose for their own
/// proposal and the same proposal always gets the same answer.
@available(iOS 16.0, macOS 13.0, visionOS 1.0, *)
struct AdaptyUIFlexStackLayout: Layout {
    let conditions: [VC.Condition]
    let direction: VC.Flex.Direction
    let screenSize: CGSize
    let orientation: VC.Orientation
    /// The axes a box with `shrink` hugs the stack on.
    let huggedAxes: Axis.Set
    /// The axes without a length from above, where the proposal is not read.
    /// See `AdaptyUIUnspecifiedProposalAxesKey`.
    var unspecifiedAxes: Axis.Set = []
    let horizontalSpacing: CGFloat
    let verticalSpacing: CGFloat
    /// Cross-axis alignment of a row: `0` top, `1` bottom.
    let verticalAnchor: CGFloat
    /// Cross-axis alignment of a column: `0` leading, `1` trailing.
    let horizontalAnchor: CGFloat

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
        for (index, frame) in solve(proposal: proposal, subviews: subviews).frames.enumerated() {
            subviews[index].place(
                at: CGPoint(x: bounds.minX + frame.origin.x, y: bounds.minY + frame.origin.y),
                anchor: .topLeading,
                proposal: ProposedViewSize(width: frame.offerWidth, height: frame.offerHeight)
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

    private func solve(proposal: ProposedViewSize, subviews: Subviews) -> AdaptyUIFlexStackSolver.Result {
        let read = proposal.withoutLength(on: unspecifiedAxes)
        let chosen = AdaptyUIFlexDirectionSolver.direction(
            conditions: conditions,
            direction: direction,
            proposedWidth: read.width,
            proposedHeight: read.height,
            hugsWidth: huggedAxes.contains(.horizontal),
            hugsHeight: huggedAxes.contains(.vertical),
            screen: screenSize,
            orientation: orientation,
            naturalSize: { stack(direction, proposal: proposal, subviews: subviews).size }
        )
        return stack(chosen, proposal: proposal, subviews: subviews)
    }

    private func stack(
        _ direction: VC.Flex.Direction,
        proposal: ProposedViewSize,
        subviews: Subviews
    ) -> AdaptyUIFlexStackSolver.Result {
        let horizontal = direction == .horizontal
        return AdaptyUIFlexStackSolver.solve(
            axis: horizontal ? .horizontal : .vertical,
            spacing: horizontal ? horizontalSpacing : verticalSpacing,
            crossAnchor: horizontal ? verticalAnchor : horizontalAnchor,
            children: subviews.map {
                .init(isSpace: $0[AdaptyUIFlexStackSpaceKey.self], priority: $0.priority)
            },
            proposedWidth: proposal.width,
            proposedHeight: proposal.height,
            measure: { index, width, height in
                subviews[index].sizeThatFits(ProposedViewSize(width: width, height: height))
            }
        )
    }
}
