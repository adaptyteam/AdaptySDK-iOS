//
//  AdaptyUIRowView.swift
//
//
//  Created by Aleksey Goncharov on 23.05.2024.
//

#if canImport(UIKit)

import Adapty
import SwiftUI

@available(iOS 15.0, *)
struct AdaptyUIRowView: View {
    @Environment(\.adaptyScreenSize)
    private var screenSize: CGSize
    @Environment(\.layoutDirection)
    private var layoutDirection: LayoutDirection
    private var row: AdaptyUI.Row

    init(_ row: AdaptyUI.Row) {
        self.row = row
    }

    private func calculateTotalWeight(
        for items: [AdaptyUI.GridItem],
        in _: GeometryProxy
    ) -> (Int, CGFloat) {
        var totalWeight = 0
        var reservedLength: CGFloat = 0.0

        for item in items {
            switch item.length {
            case let .fixed(value):
                reservedLength += value.points(screenSize: screenSize.width)
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
                        size = .fixed(length.points(screenSize: screenSize.width))
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
                        AdaptyUIElementView(row.items[idx].content)
                    }
                }
            )
            .onGeometrySizeChange { contentsSize = $0 }
        }
        .frame(height: contentsSize.height)
    }
}

#if DEBUG

@available(iOS 15.0, *)
#Preview {
    ScrollView {
        VStack {
            Text("Top")

            AdaptyUIRowView(
                AdaptyUI.Row.create(
                    spacing: 6.0,
                    items: [
                        .create(
                            length: .fixed(.point(32)),
                            content: .text(.testBodyShort, nil)
                        ),
                        .create(
                            length: .weight(2),
                            content: .text(.testBodyShort, nil)
                        ),
                        .create(
                            length: .weight(3),
                            content: .text(.testBodyShort, nil)
                        ),
                    ]
                )
            )
            .background(Color.green)

            Text("Bottom")
        }
        .withScreenSize(.init(width: 320, height: 240))
        .environmentObject(AdaptyProductsViewModel(logId: "Preview"))
        .environmentObject(AdaptyUIActionsViewModel(logId: "Preview"))
        .environmentObject(AdaptySectionsViewModel(logId: "Preview"))
        .environmentObject(AdaptyTagResolverViewModel(tagResolver: nil))
    }
}

#endif

#endif
