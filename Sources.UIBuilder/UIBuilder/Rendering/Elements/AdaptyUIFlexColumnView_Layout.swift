//
//  AdaptyUIFlexColumnView_Layout.swift
//  AdaptyUIBuilder
//

#if canImport(UIKit)

import SwiftUI

/// `Layout`-based counterpart of `AdaptyUIFlexColumnView`, selected by the
/// `#available` branch in `AdaptyUIElementView`. The original view is untouched
/// and keeps serving iOS 15 / macOS 12.
///
/// Besides dropping the measurement round-trip, this loses the
/// `.frame(minWidth: contentsSize.width)` floor the old `weightedBody` needed to
/// stop its greedy `GeometryReader` from collapsing: an unproposed axis is now an
/// explicit `nil` inside `sizeThatFits`.
@available(iOS 16.0, macOS 13.0, *)
@MainActor
struct AdaptyUIFlexColumnView_Layout<ScreenHolderContent: View>: View {
    @Environment(\.adaptyScreenSize)
    private var screenSize: CGSize
    @Environment(\.adaptySafeAreaInsets)
    private var safeArea: EdgeInsets
    @Environment(\.layoutDirection)
    private var layoutDirection: LayoutDirection

    private let column: VC.Column
    private let screenHolderBuilder: () -> ScreenHolderContent

    init(
        _ column: VC.Column,
        @ViewBuilder screenHolderBuilder: @escaping () -> ScreenHolderContent
    ) {
        self.column = column
        self.screenHolderBuilder = screenHolderBuilder
    }

    var body: some View {
        AdaptyUIWeightedStackLayout(
            resolution: .fixed(
                .vertical,
                .init(mode: column.height, spacing: CGFloat(column.spacing))
            ),
            screenSize: screenSize,
            safeArea: safeArea
        ) {
            ForEach(0 ..< column.items.count, id: \.self) { index in
                let item = column.items[index]

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
    }
}

#endif
