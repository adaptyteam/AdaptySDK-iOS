//
//  AdaptyUIFlexRowView.swift
//
//
//  Created by Aleksey Goncharov on 20.03.2026.
//

#if canImport(UIKit)

import SwiftUI

struct AdaptyUIFlexRowView<ScreenHolderContent: View>: View {
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

    private func calculateTotalWeight(
        for items: [VC.GridItem],
        in _: GeometryProxy
    ) -> (Int, CGFloat) {
        var totalWeight = 0
        var reservedLength: CGFloat = 0.0

        for item in items {
            switch item.length {
            case let .fixed(value):
                reservedLength += value.points(
                    screenSize: screenSize.width,
                    safeAreaStart: safeArea.leading,
                    safeAreaEnd: safeArea.trailing
                )
            case let .weight(value):
                totalWeight += value
            }
        }

        if row.spacing > 0 {
            reservedLength += CGFloat(row.spacing * Double(items.count - 1))
        }

        return (totalWeight, reservedLength)
    }

    private func itemWidth(
        _ item: VC.GridItem,
        totalWeight: Int,
        weightsAvailableLength: CGFloat
    ) -> CGFloat {
        switch item.length {
        case let .fixed(length):
            length.points(
                screenSize: screenSize.width,
                safeAreaStart: safeArea.leading,
                safeAreaEnd: safeArea.trailing
            )
        case let .weight(weight):
            totalWeight > 0 ? (Double(weight) / Double(totalWeight)) * weightsAvailableLength : 0
        }
    }

    @State private var contentsSize: CGSize = .zero

    var body: some View {
        switch row.width {
        case .hug:
            fixedBody
        case .fill, .legacy:
            weightedBody
        }
    }

    private var fixedBody: some View {
        HStack(spacing: row.spacing) {
            ForEach(0 ..< row.items.count, id: \.self) { idx in
                let item = row.items[idx]

                AdaptyUIElementView(
                    item.content,
                    screenHolderBuilder: {
                        if idx == 0 {
                            screenHolderBuilder()
                        } else {
                            EmptyView()
                        }
                    }
                )
                .frame(
                    width: itemWidth(
                        item,
                        totalWeight: 0,
                        weightsAvailableLength: 0
                    )
                )
                .frame(
                    maxHeight: .infinity,
                    alignment: Alignment.from(
                        horizontal: item.horizontalAlignment.swiftuiValue(with: layoutDirection),
                        vertical: item.verticalAlignment.swiftuiValue
                    )
                )
            }
        }
    }

    private var weightedBody: some View {
        GeometryReader { proxy in
            let (totalWeight, reservedLength) = calculateTotalWeight(for: row.items, in: proxy)
            let weightsAvailableLength = max(0, proxy.size.width - reservedLength)

            HStack(spacing: row.spacing) {
                ForEach(0 ..< row.items.count, id: \.self) { idx in
                    let item = row.items[idx]

                    AdaptyUIElementView(
                        item.content,
                        screenHolderBuilder: {
                            if idx == 0 {
                                screenHolderBuilder()
                            } else {
                                EmptyView()
                            }
                        }
                    )
                    .frame(
                        width: itemWidth(
                            item,
                            totalWeight: totalWeight,
                            weightsAvailableLength: weightsAvailableLength
                        )
                    )
                    .frame(
                        maxHeight: .infinity,
                        alignment: Alignment.from(
                            horizontal: item.horizontalAlignment.swiftuiValue(with: layoutDirection),
                            vertical: item.verticalAlignment.swiftuiValue
                        )
                    )
                }
            }
            .frame(maxWidth: .infinity, alignment: .topLeading)
            .onGeometrySizeChange { contentsSize = $0 }
        }
        .frame(minHeight: contentsSize.height)
    }
}

#endif
