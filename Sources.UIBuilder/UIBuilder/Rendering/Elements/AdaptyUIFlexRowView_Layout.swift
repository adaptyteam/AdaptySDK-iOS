//
//  AdaptyUIFlexRowView_Layout.swift
//  AdaptyUIBuilder
//

#if canImport(UIKit)

import SwiftUI

/// `Layout`-based counterpart of `AdaptyUIFlexRowView`, selected by the
/// `#available` branch in `AdaptyUIElementView`. The original view is untouched
/// and keeps serving iOS 15 / macOS 12.
///
/// Both sizing modes go through one `AdaptyUIWeightedStackLayout`, so there is no
/// `weightedBody` / `fixedBody` split and no measurement round-trip: the length
/// to distribute arrives as the layout `proposal`.
///
/// `externalSize` is gone on purpose. It existed so `AdaptyUIFlexView` could hand
/// down the size it had measured; a nested `Layout` receives that as its own
/// proposal instead.
@available(iOS 16.0, macOS 13.0, *)
@MainActor
struct AdaptyUIFlexRowView_Layout<ScreenHolderContent: View>: View {
    @Environment(\.adaptyScreenSize)
    private var screenSize: CGSize
    @Environment(\.adaptySafeAreaInsets)
    private var safeArea: EdgeInsets
    @Environment(\.layoutDirection)
    private var layoutDirection: LayoutDirection

    private let row: VC.Row
    private let screenHolderBuilder: () -> ScreenHolderContent

    init(
        _ row: VC.Row,
        @ViewBuilder screenHolderBuilder: @escaping () -> ScreenHolderContent
    ) {
        self.row = row
        self.screenHolderBuilder = screenHolderBuilder
    }

    var body: some View {
        AdaptyUIWeightedStackLayout(
            resolution: .fixed(
                .horizontal,
                .init(mode: row.width, spacing: CGFloat(row.spacing))
            ),
            screenSize: screenSize,
            safeArea: safeArea
        ) {
            ForEach(0 ..< row.items.count, id: \.self) { index in
                let item = row.items[index]

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
