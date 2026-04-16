//
//  AdaptyUIFlexColumnView.swift
//
//
//  Created by Aleksey Goncharov on 20.03.2026.
//

#if canImport(UIKit)

import SwiftUI

struct AdaptyUIFlexColumnView<ScreenHolderContent: View>: View {
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
                    screenSize: screenSize.height,
                    safeAreaStart: safeArea.top,
                    safeAreaEnd: safeArea.bottom
                )
            case let .weight(value):
                totalWeight += value
            }
        }

        if column.spacing > 0 {
            reservedLength += CGFloat(column.spacing * Double(items.count - 1))
        }

        return (totalWeight, reservedLength)
    }

    private func itemHeight(
        _ item: VC.GridItem,
        totalWeight: Int,
        weightsAvailableLength: CGFloat
    ) -> CGFloat {
        switch item.length {
        case let .fixed(length):
            length.points(
                screenSize: screenSize.height,
                safeAreaStart: safeArea.top,
                safeAreaEnd: safeArea.bottom
            )
        case let .weight(weight):
            (Double(weight) / Double(totalWeight)) * weightsAvailableLength
        }
    }

    private var hasWeights: Bool {
        column.items.contains { if case .weight = $0.length { return true } else { return false } }
    }

    @State private var contentsSize: CGSize = .zero

    var body: some View {
        if hasWeights {
            weightedBody
        } else {
            fixedBody
        }
    }

    private var fixedBody: some View {
        VStack(spacing: column.spacing) {
            ForEach(0 ..< column.items.count, id: \.self) { idx in
                let item = column.items[idx]

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
                    height: itemHeight(
                        item,
                        totalWeight: 0,
                        weightsAvailableLength: 0
                    ),
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
            let (totalWeight, reservedLength) = calculateTotalWeight(for: column.items, in: proxy)
            let weightsAvailableLength = proxy.size.height - reservedLength

            VStack(spacing: column.spacing) {
                ForEach(0 ..< column.items.count, id: \.self) { idx in
                    let item = column.items[idx]

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
                        maxWidth: .infinity,
                        alignment: Alignment.from(
                            horizontal: item.horizontalAlignment.swiftuiValue(with: layoutDirection),
                            vertical: item.verticalAlignment.swiftuiValue
                        )
                    )
                    .frame(
                        height: itemHeight(
                            item,
                            totalWeight: totalWeight,
                            weightsAvailableLength: weightsAvailableLength
                        )
                    )
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .onGeometrySizeChange { contentsSize = $0 }
        }
        .frame(minWidth: contentsSize.width)
    }
}

#endif
