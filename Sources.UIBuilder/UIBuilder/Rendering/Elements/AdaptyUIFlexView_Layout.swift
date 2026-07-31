//
//  AdaptyUIFlexView_Layout.swift
//  AdaptyUIBuilder
//

#if canImport(UIKit)

import SwiftUI

/// `Layout`-based counterpart of `AdaptyUIFlexView`, selected by the `#available`
/// branch in `AdaptyUIElementView`. The original view is untouched and keeps
/// serving iOS 15 / macOS 12.
///
/// `Flex` branches its **direction**, not its content: `asRow` and `asColumn`
/// carry the same `items` and differ only in main-axis sizing mode and spacing.
/// So a single `AdaptyUIWeightedStackLayout` covers both, choosing the axis from
/// the proposal inside `sizeThatFits` — no `@State`, and none of the machinery the
/// old view needs:
///
/// - no `hugWidth` / `hugHeight` pins. Hugging is now simply "return a size
///   smaller than the proposal", which cannot feed back into the incoming
///   proposal, so the direction cannot oscillate.
/// - no `parentProposal(from:)`. It existed to break that oscillation by freezing
///   `available_*` on a hugging axis, which cost the flex the ability to notice
///   its parent shrinking. The condition is now evaluated from the live proposal
///   on every pass — the one intentional behaviour change of this PoC.
/// - no `contentSize` observer, so no "deliberately not reset here" invariant.
@available(iOS 16.0, macOS 13.0, *)
@MainActor
struct AdaptyUIFlexView_Layout<ScreenHolderContent: View>: View {
    @Environment(\.adaptyScreenSize)
    private var screenSize: CGSize
    @Environment(\.adaptySafeAreaInsets)
    private var safeArea: EdgeInsets
    @Environment(\.adaptyInterfaceOrientation)
    private var orientation: VC.Orientation
    @Environment(\.layoutDirection)
    private var layoutDirection: LayoutDirection

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
        AdaptyUIWeightedStackLayout(
            resolution: .conditional(
                condition: flex.condition,
                matchedDirection: flex.direction,
                orientation: orientation,
                horizontal: .init(mode: flex.width, spacing: CGFloat(flex.horizontalSpacing)),
                vertical: .init(mode: flex.height, spacing: CGFloat(flex.verticalSpacing))
            ),
            screenSize: screenSize,
            safeArea: safeArea
        ) {
            ForEach(0 ..< flex.items.count, id: \.self) { index in
                let item = flex.items[index]

                AdaptyUIElementView(
                    item.content,
                    screenHolderBuilder: screenHolderBuilder
                )
                .layoutValue(key: AdaptyUIGridItemLengthKey.self, value: item.length)
                .layoutValue(
                    key: AdaptyUIGridItemAnchorKey.self,
                    value: item.anchor(with: layoutDirection)
                )
            }
        }
        .adaptyAnimateAxisFlip(
            flex.transition,
            orientation: orientation,
            screenSize: screenSize
        )
    }
}

#endif
