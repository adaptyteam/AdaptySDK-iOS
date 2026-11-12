//
//  AdaptyUIWeightedView.swift
//  AdaptyUIBuilder
//

#if canImport(UIKit)

import SwiftUI

/// Renders a `Row` or a `Column` with `hug` or `fill` sizing.
///
/// The view resolves units and alignment against the environment and hands plain
/// numbers to `AdaptyUIWeightedLayout`, so the layout arithmetic stays independent
/// of both the environment and the interface direction.
@available(iOS 16.0, macOS 13.0, visionOS 1.0, *)
struct AdaptyUIWeightedView<ScreenHolderContent: View>: View {
    @Environment(\.adaptyScreenSize)
    private var screenSize: CGSize
    @Environment(\.adaptySafeAreaInsets)
    private var safeArea: EdgeInsets
    @Environment(\.layoutDirection)
    private var layoutDirection: LayoutDirection
    @Environment(\.adaptyElementPool)
    private var elementPool: [VC.Element]

    private let axis: AdaptyUIWeightedSolver.Axis
    private let mainAxisSizing: AdaptyUILayoutSizing
    private let crossAxisSizing: AdaptyUILayoutSizing
    private let spacing: Double
    private let items: [VC.GridItem]
    private let screenHolderBuilder: () -> ScreenHolderContent

    init(
        axis: AdaptyUIWeightedSolver.Axis,
        mainAxisSizing: AdaptyUILayoutSizing,
        crossAxisSizing: AdaptyUILayoutSizing,
        spacing: Double,
        items: [VC.GridItem],
        @ViewBuilder screenHolderBuilder: @escaping () -> ScreenHolderContent
    ) {
        self.axis = axis
        self.mainAxisSizing = mainAxisSizing
        self.crossAxisSizing = crossAxisSizing
        self.spacing = spacing
        self.items = items
        self.screenHolderBuilder = screenHolderBuilder
    }

    var body: some View {
        AdaptyUIWeightedLayout(
            axis: axis,
            mainAxisSizing: mainAxisSizing,
            crossAxisSizing: crossAxisSizing,
            spacing: spacing.cgFloatValue,
            items: items.map {
                $0.weightedItem(axis, screenSize, safeArea, layoutDirection, elementPool)
            }
        ) {
            AdaptyUIWeightedItemsView(items: items, axis: axis, screenHolderBuilder: screenHolderBuilder)
        }
    }
}

/// The elements of `items`, each marked with its item for `AdaptyUIWeightedLayout`.
@available(iOS 16.0, macOS 13.0, visionOS 1.0, *)
struct AdaptyUIWeightedItemsView<ScreenHolderContent: View>: View {
    let items: [VC.GridItem]
    /// The axis the items are laid out along, where it is known when the view is
    /// built: a cell of a fixed length hands that length down on it.
    let axis: AdaptyUIWeightedSolver.Axis?
    let screenHolderBuilder: () -> ScreenHolderContent

    @Environment(\.adaptyUnspecifiedProposalAxes)
    private var unspecifiedAxes: Axis.Set

    var body: some View {
        ForEach(0 ..< items.count, id: \.self) { idx in
            // Marked rather than wrapped, so the layout reaches the element's own
            // views and lays them out as the element rendered them.
            AdaptyUIElementView(
                items[idx].content,
                screenHolderBuilder: screenHolderBuilder
            )
            .collapsedCellClipped(collapses(items[idx]), axis: .vertical)
            .declaringProposal(axis == .horizontal ? .horizontal : .vertical, unspecified: fixes(items[idx]) ? false : nil)
            .layoutValue(key: AdaptyUIWeightedItemKey.self, value: idx)
        }
    }

    /// A column without a height gives a weighted item none, and its content must
    /// not draw over its neighbours, as it would at its own size. A row without a
    /// width sizes weighted items by their content instead.
    private func collapses(_ item: VC.GridItem) -> Bool {
        axis == .vertical && item.isWeight && unspecifiedAxes.contains(.vertical)
    }

    private func fixes(_ item: VC.GridItem) -> Bool {
        guard axis != nil, case .fixed = item.length else { return false }
        return true
    }
}

/// A weighted cell collapsed to no length on `axis` hides its content instead of
/// drawing it at the content's own size over the neighbouring cells.
extension View {
    @ViewBuilder
    func collapsedCellClipped(_ collapsed: Bool, axis: Axis) -> some View {
        if collapsed {
            frame(width: axis == .horizontal ? 0 : nil, height: axis == .vertical ? 0 : nil).clipped()
        } else {
            self
        }
    }
}

extension VC.GridItem {
    var isWeight: Bool {
        if case .weight = length { true } else { false }
    }

    /// The item as the weighted layout along `axis` sees it: units resolved to
    /// points, alignments to anchors for the layout direction.
    func weightedItem(
        _ axis: AdaptyUIWeightedSolver.Axis,
        _ screenSize: CGSize,
        _ safeArea: EdgeInsets,
        _ layoutDirection: LayoutDirection,
        _ elementPool: [VC.Element]
    ) -> AdaptyUIWeightedSolver.Item {
        let points: AdaptyUIWeightedSolver.Length =
            switch length {
            case let .fixed(unit):
                .points(unit.points(axis == .horizontal ? .horizontal : .vertical, screenSize, safeArea).cgFloatValue)
            case let .weight(weight):
                .weight(weight)
            }
        return .init(
            length: points,
            anchorX: horizontalAlignment.anchorFraction(with: layoutDirection),
            anchorY: verticalAlignment.anchorFraction,
            // A row measures its children without a height and places them with
            // its own. Content that picks its layout from `available_height` is
            // placed without one too, so it lays out what it was measured for —
            // at the cost of not stretching to a taller neighbour.
            placesAsMeasured: axis == .horizontal && elementPool.picksLayoutFromHeight(content)
        )
    }
}

#endif
