//
//  AdaptyUIWeightedStackLayout.swift
//  AdaptyUIBuilder
//

#if canImport(UIKit)

import SwiftUI

/// Declared main-axis length of an item, still carrying its `VC.Unit`.
///
/// The unit is resolved inside the layout rather than by the view, because a
/// `screen` unit resolves against the width in row direction and the height in
/// column direction — and for `Flex` the direction is only known once the
/// proposal is in.
@available(iOS 16.0, macOS 13.0, *)
struct AdaptyUIGridItemLengthKey: LayoutValueKey {
    static let defaultValue: VC.GridItem.Length = .weight(1)
}

/// Where an item sits inside its slot. `x`/`y` are 0…1 fractions with RTL
/// already applied by the view layer.
@available(iOS 16.0, macOS 13.0, *)
struct AdaptyUIGridItemAnchorKey: LayoutValueKey {
    static let defaultValue: UnitPoint = .center
}

/// One-pass replacement for the weighted `HStack` / `VStack` bodies of
/// `AdaptyUIFlexRowView`, `AdaptyUIFlexColumnView` and `AdaptyUIFlexView`.
///
/// Those bodies need the length the parent offers before they can split it
/// between weighted items, and they obtain it by measuring themselves — a greedy
/// `GeometryReader` or an `onGeometrySizeChange` observer feeding `@State` —
/// which costs an extra layout pass, forced the "nil until the first measurement"
/// workaround in Row, and in Flex forced `parentProposal(from:)` to freeze
/// `available_*` on a hugging axis to stop the direction oscillating. A `Layout`
/// receives that length as `proposal`, so nothing feeds back and none of it is
/// needed.
///
/// Parity notes, all mirroring the modifiers used today:
/// - the main axis hugs its content in `hug` mode and takes the proposal in
///   `fill` / `legacy` mode;
/// - the cross axis differs per axis, exactly as the two bodies differ: a row
///   hugs its height (`.fixedSize(horizontal: false, vertical: true)`), a column
///   fills its width (`.frame(maxWidth: .infinity)`);
/// - every item is proposed its whole slot and then aligned inside it, which is
///   what the chained `.frame(length, alignment:)` + `.frame(maxCross:, alignment:)`
///   pair does.
@available(iOS 16.0, macOS 13.0, *)
struct AdaptyUIWeightedStackLayout: Layout {
    /// Main-axis sizing and spacing for one direction.
    struct AxisParams {
        let mode: VC.AutoSizeMode
        let spacing: CGFloat
    }

    /// How the main axis is chosen.
    enum AxisResolution {
        /// `Row` / `Column`: known up front.
        case fixed(Axis, AxisParams)
        /// `Flex`: follows a condition evaluated against the proposal.
        case conditional(
            condition: [VC.Condition],
            matchedDirection: VC.Flex.Direction,
            orientation: VC.Orientation,
            horizontal: AxisParams,
            vertical: AxisParams
        )
    }

    struct Cache {
        /// Direction resolved from the last usable proposal. SwiftUI also probes a
        /// layout with degenerate proposals (`.unspecified`, `.infinity`) to learn
        /// how flexible it is; re-deciding the direction on those would report
        /// sizes for two different directions within one pass, so the probes reuse
        /// this instead.
        var direction: VC.Flex.Direction?
    }

    let resolution: AxisResolution
    let screenSize: CGSize
    let safeArea: EdgeInsets

    func makeCache(subviews: Subviews) -> Cache { Cache() }

    func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout Cache
    ) -> CGSize {
        guard !subviews.isEmpty else { return .zero }

        let plan = plan(for: proposal, cache: &cache)
        let lengths = lengths(subviews: subviews, plan: plan, availableMain: plan.main(of: proposal))
        let crossProposal = plan.cross(of: proposal)

        var contentMain: CGFloat = 0
        var maxCross: CGFloat = 0

        for (index, subview) in subviews.enumerated() {
            let measured = subview.sizeThatFits(
                plan.makeProposal(main: lengths[index], cross: plan.crossMeasure(crossProposal))
            )
            // A nil length means the item was left unconstrained, so its own
            // measurement is what it contributes.
            contentMain += lengths[index] ?? plan.main(of: measured)
            maxCross = max(maxCross, plan.cross(of: measured))
        }

        contentMain += plan.totalSpacing(count: subviews.count)

        let resultMain: CGFloat = switch plan.params.mode {
        case .hug: contentMain
        case .fill, .legacy: plan.main(of: proposal) ?? contentMain
        }

        let resultCross: CGFloat = switch plan.axis {
        case .horizontal: maxCross // row hugs its height
        case .vertical: crossProposal ?? maxCross // column fills its width
        }

        return plan.makeSize(main: resultMain, cross: resultCross)
    }

    func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout Cache
    ) {
        guard !subviews.isEmpty else { return }

        // The axis comes from the same proposal `sizeThatFits` saw, not from the
        // granted bounds: the bounds are derived from the size we already reported,
        // so deciding again from them could pick a different direction within one
        // pass — reporting one axis' size and then placing along the other.
        // The distribution below does use the bounds, which are the real extent to
        // divide up.
        let plan = plan(for: proposal, cache: &cache)
        let crossExtent = plan.cross(of: bounds.size)
        let lengths = lengths(subviews: subviews, plan: plan, availableMain: plan.main(of: bounds.size))

        var cursor = plan.mainOrigin(of: bounds)
        let crossOrigin = plan.crossOrigin(of: bounds)

        for (index, subview) in subviews.enumerated() {
            let slotProposal = plan.makeProposal(main: lengths[index], cross: crossExtent)
            let measured = subview.sizeThatFits(slotProposal)
            let slotMain = lengths[index] ?? plan.main(of: measured)

            let slot = plan.makeRect(
                mainOrigin: cursor,
                crossOrigin: crossOrigin,
                main: slotMain,
                cross: crossExtent
            )
            let anchor = subview[AdaptyUIGridItemAnchorKey.self]

            subview.place(
                at: CGPoint(
                    x: slot.minX + (slot.width - measured.width) * anchor.x,
                    y: slot.minY + (slot.height - measured.height) * anchor.y
                ),
                anchor: .topLeading,
                proposal: slotProposal
            )

            cursor += slotMain
            if index < subviews.count - 1, plan.params.spacing > 0 {
                cursor += plan.params.spacing
            }
        }
    }

    // MARK: - Resolving the axis

    /// Axis, sizing mode and spacing for one layout pass.
    fileprivate struct Plan {
        let axis: Axis
        let params: AxisParams
        let screenSize: CGSize
        let safeArea: EdgeInsets
    }

    private func plan(for proposal: ProposedViewSize, cache: inout Cache) -> Plan {
        switch resolution {
        case let .fixed(axis, params):
            return Plan(axis: axis, params: params, screenSize: screenSize, safeArea: safeArea)

        case let .conditional(condition, matchedDirection, orientation, horizontal, vertical):
            let direction = resolveDirection(
                condition: condition,
                matchedDirection: matchedDirection,
                orientation: orientation,
                proposal: proposal,
                cache: &cache
            )
            return switch direction {
            case .horizontal:
                Plan(axis: .horizontal, params: horizontal, screenSize: screenSize, safeArea: safeArea)
            case .vertical:
                Plan(axis: .vertical, params: vertical, screenSize: screenSize, safeArea: safeArea)
            }
        }
    }

    private func resolveDirection(
        condition: [VC.Condition],
        matchedDirection: VC.Flex.Direction,
        orientation: VC.Orientation,
        proposal: ProposedViewSize,
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

    // MARK: - Length distribution

    private func lengths(
        subviews: Subviews,
        plan: Plan,
        availableMain: CGFloat?
    ) -> [CGFloat?] {
        let declared = subviews.map { subview in
            subview[AdaptyUIGridItemLengthKey.self].resolved(
                plan.unitDirection,
                plan.screenSize,
                plan.safeArea
            )
        }

        return switch plan.params.mode {
        case .hug:
            VC.GridItem.huggedLengths(declared)
        case .fill, .legacy:
            VC.GridItem.distributedLengths(
                declared,
                spacing: Double(plan.params.spacing),
                availableLength: availableMain
            )
        }
    }
}

// MARK: - Axis geometry

@available(iOS 16.0, macOS 13.0, *)
private extension AdaptyUIWeightedStackLayout.Plan {
    var unitDirection: VC.Unit.Direction {
        switch axis {
        case .horizontal: .horizontal
        case .vertical: .vertical
        }
    }

    /// What the cross axis is proposed to items while they are measured.
    ///
    /// A row hugs its height, and `.fixedSize(horizontal: false, vertical: true)`
    /// achieves that by proposing `nil`: items report their **ideal** cross extent,
    /// so the row can end up taller than the proposal instead of squeezing them
    /// into it. Passing the bounded proposal through instead truncates text that
    /// does not fit — a row of fixed-length items inside a box with a fixed height, for
    /// instance. Items are still proposed the resulting extent when
    /// placed, which is what their `.frame(maxHeight: .infinity)` does today.
    ///
    /// A column has no `fixedSize`: its items get `.frame(maxWidth: .infinity)`
    /// under the width the `GeometryReader` handed down, so the bounded proposal is
    /// passed through as-is.
    func crossMeasure(_ crossProposal: CGFloat?) -> CGFloat? {
        switch axis {
        case .horizontal: nil
        case .vertical: crossProposal
        }
    }

    func totalSpacing(count: Int) -> CGFloat {
        guard params.spacing > 0 else { return 0 }
        return params.spacing * CGFloat(max(0, count - 1))
    }

    func main(of size: CGSize) -> CGFloat {
        switch axis {
        case .horizontal: size.width
        case .vertical: size.height
        }
    }

    func cross(of size: CGSize) -> CGFloat {
        switch axis {
        case .horizontal: size.height
        case .vertical: size.width
        }
    }

    func main(of proposal: ProposedViewSize) -> CGFloat? {
        switch axis {
        case .horizontal: proposal.width
        case .vertical: proposal.height
        }
    }

    func cross(of proposal: ProposedViewSize) -> CGFloat? {
        switch axis {
        case .horizontal: proposal.height
        case .vertical: proposal.width
        }
    }

    func makeProposal(main: CGFloat?, cross: CGFloat?) -> ProposedViewSize {
        switch axis {
        case .horizontal: ProposedViewSize(width: main, height: cross)
        case .vertical: ProposedViewSize(width: cross, height: main)
        }
    }

    func makeSize(main: CGFloat, cross: CGFloat) -> CGSize {
        switch axis {
        case .horizontal: CGSize(width: main, height: cross)
        case .vertical: CGSize(width: cross, height: main)
        }
    }

    func mainOrigin(of bounds: CGRect) -> CGFloat {
        switch axis {
        case .horizontal: bounds.minX
        case .vertical: bounds.minY
        }
    }

    func crossOrigin(of bounds: CGRect) -> CGFloat {
        switch axis {
        case .horizontal: bounds.minY
        case .vertical: bounds.minX
        }
    }

    func makeRect(
        mainOrigin: CGFloat,
        crossOrigin: CGFloat,
        main: CGFloat,
        cross: CGFloat
    ) -> CGRect {
        switch axis {
        case .horizontal:
            CGRect(x: mainOrigin, y: crossOrigin, width: main, height: cross)
        case .vertical:
            CGRect(x: crossOrigin, y: mainOrigin, width: cross, height: main)
        }
    }
}

// MARK: - Alignment → anchor fraction

extension SwiftUI.HorizontalAlignment {
    /// 0 at the leading edge, 1 at the trailing edge.
    var adaptyAnchorFraction: CGFloat {
        if self == .leading { return 0 }
        if self == .trailing { return 1 }
        return 0.5
    }
}

extension SwiftUI.VerticalAlignment {
    /// 0 at the top edge, 1 at the bottom edge.
    var adaptyAnchorFraction: CGFloat {
        if self == .top { return 0 }
        if self == .bottom { return 1 }
        return 0.5
    }
}

#endif
