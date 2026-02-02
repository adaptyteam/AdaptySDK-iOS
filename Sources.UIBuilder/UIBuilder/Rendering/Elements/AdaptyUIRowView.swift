//
//  AdaptyUIRowView.swift
//
//
//  Created by Aleksey Goncharov on 23.05.2024.
//

#if canImport(UIKit)

import SwiftUI

struct AdaptyUIRowView<ScreenHolderContent: View>: View {
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

    @State private var contentsSize: CGSize = .zero

    var body: some View {
        GeometryReader { proxy in
            let (totalWeight, reservedLength) = calculateTotalWeight(for: row.items, in: proxy)
            let weightsAvailableLength = proxy.size.width - reservedLength

            LazyVGrid(
                columns: row.items.map { item in
                    let size: GridItem.Size

                    switch item.length {
                    case let .fixed(length):
                        size = .fixed(length.points(screenSize: screenSize.width,
                                                    safeAreaStart: safeArea.leading,
                                                    safeAreaEnd: safeArea.trailing))
                    case let .weight(weight):
                        size = .fixed((Double(weight) / Double(totalWeight)) * weightsAvailableLength)
                    }

                    return GridItem(
                        size,
                        spacing: row.spacing,
                        alignment: Alignment.from(
                            horizontal: item.horizontalAlignment.swiftuiValue(with: layoutDirection),
                            vertical: item.verticalAlignment.swiftuiValue
                        )
                    )
                },
                spacing: 0.0,
                content: {
                    ForEach(0 ..< row.items.count, id: \.self) { idx in
                        AdaptyUIElementView(
                            row.items[idx].content,
                            screenHolderBuilder: {
                                if idx == 0 {
                                    screenHolderBuilder() // TODO: x check
                                } else {
                                    EmptyView()
                                }
                            }
                        )
                    }
                }
            )
            .onGeometrySizeChange { contentsSize = $0 }
        }
        .frame(height: contentsSize.height)
    }
}

#endif
