//
//  AdaptyUIFlexView.swift
//  AdaptyUIBuilder
//

#if canImport(UIKit)

import SwiftUI

/// Renders a `Flex`: resolves the environment into numbers and leaves the choice
/// of direction to `AdaptyUIFlexLayout`, which sees the proposal. As a row the flex
/// is a `Row` with its `width` and horizontal spacing, as a column a `Column` with
/// its `height` and vertical spacing.
@MainActor
@available(iOS 16.0, macOS 13.0, visionOS 1.0, *)
struct AdaptyUIFlexView<ScreenHolderContent: View>: View {
    @Environment(\.adaptyScreenSize) private var screenSize: CGSize
    @Environment(\.adaptySafeAreaInsets) private var safeArea: EdgeInsets
    @Environment(\.adaptyInterfaceOrientation) private var orientation: VC.Orientation
    @Environment(\.adaptyHuggedAxes) private var huggedAxes: Axis.Set
    @Environment(\.adaptyUnspecifiedProposalAxes) private var unspecifiedAxes: Axis.Set
    @Environment(\.layoutDirection) private var layoutDirection: LayoutDirection
    @Environment(\.adaptyElementPool) private var elementPool: [VC.Element]

    private let flex: VC.Flex
    private let screenHolderBuilder: () -> ScreenHolderContent

    init(
        _ flex: VC.Flex,
        @ViewBuilder screenHolderBuilder: @escaping () -> ScreenHolderContent
    ) {
        self.flex = flex
        self.screenHolderBuilder = screenHolderBuilder
    }

    var body: some View {
        if let animation = flex.transition?.swiftUIAnimation {
            // The direction is chosen inside the layout pass, where no animation
            // can be started. A reorientation follows the screen almost always — a
            // rotation, a resized window — so the transition animates the changes
            // these bring.
            layout
                .animation(animation, value: screenSize)
                .animation(animation, value: orientation)
        } else {
            layout
        }
    }

    private var layout: some View {
        AdaptyUIFlexLayout(
            conditions: flex.condition,
            direction: flex.direction,
            screenSize: screenSize,
            orientation: orientation,
            huggedAxes: huggedAxes,
            unspecifiedAxes: unspecifiedAxes,
            row: weighted(.horizontal, flex.width, flex.horizontalSpacing),
            column: weighted(.vertical, flex.height, flex.verticalSpacing)
        ) {
            // The direction is chosen in the layout pass, after the environment
            // is set, so a cell of a fixed length cannot declare that it hands a
            // length down: under a scroll a `switch`, `flex` or `flex_stack` in it
            // compares `available_*` with the screen on that axis.
            AdaptyUIWeightedItemsView(items: flex.items, axis: nil, screenHolderBuilder: screenHolderBuilder)
        }
    }

    /// The flex laid out along `axis`. A row has always hugged its height and a
    /// column filled its width, as `Row` and `Column` do.
    private func weighted(
        _ axis: AdaptyUIWeightedSolver.Axis,
        _ sizing: VC.AutoSizeMode,
        _ spacing: Double
    ) -> AdaptyUIWeightedLayout {
        AdaptyUIWeightedLayout(
            axis: axis,
            mainAxisSizing: sizing == .hug ? .hug : .fill,
            crossAxisSizing: axis == .horizontal ? .hug : .fill,
            spacing: spacing.cgFloatValue,
            items: flex.items.map { $0.weightedItem(axis, screenSize, safeArea, layoutDirection, elementPool) }
        )
    }
}

#endif
