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
            items: items.map(layoutItem)
        ) {
            ForEach(0 ..< items.count, id: \.self) { idx in
                // Marked rather than wrapped, so the layout reaches the element's
                // own views and lays them out as the element rendered them.
                AdaptyUIElementView(
                    items[idx].content,
                    screenHolderBuilder: screenHolderBuilder
                )
                .layoutValue(key: AdaptyUIWeightedItemKey.self, value: idx)
            }
        }
    }

    private func layoutItem(_ item: VC.GridItem) -> AdaptyUIWeightedSolver.Item {
        .init(
            length: layoutLength(item.length),
            anchorX: item.horizontalAlignment.anchorFraction(with: layoutDirection),
            anchorY: item.verticalAlignment.anchorFraction,
            // A row measures its children without a height and places them with
            // its own. Content that picks its layout from `available_height` is
            // placed without one too, so it lays out what it was measured for —
            // at the cost of not stretching to a taller neighbour.
            placesAsMeasured: axis == .horizontal && elementPool.picksLayoutFromHeight(item.content)
        )
    }

    private func layoutLength(_ length: VC.GridItem.Length) -> AdaptyUIWeightedSolver.Length {
        switch length {
        case let .fixed(unit):
            .points(unit.points(axis == .horizontal ? .horizontal : .vertical, screenSize, safeArea).cgFloatValue)
        case let .weight(weight):
            .weight(weight)
        }
    }
}

#endif
