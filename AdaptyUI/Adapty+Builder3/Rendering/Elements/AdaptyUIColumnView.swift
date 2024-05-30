//
//  AdaptyUIColumnView.swift
//  
//
//  Created by Aleksey Goncharov on 30.05.2024.
//

#if canImport(UIKit)

import Adapty
import SwiftUI

@available(iOS 15.0, *)
struct AdaptyUIColumnView: View {
    @Environment(\.adaptyScreenSize)
    private var screenSize: CGSize

    var column: AdaptyUI.Column

    init(_ column: AdaptyUI.Column) {
        self.column = column
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
                reservedLength += value.points(screenSize: screenSize.height)
            case let .weight(value):
                totalWeight += value
            }
        }

        if column.spacing > 0 {
            reservedLength += CGFloat(column.spacing * Double(items.count - 1))
        }

        return (totalWeight, reservedLength)
    }

    @State private var contentsSize: CGSize = .zero

    var body: some View {
        GeometryReader { proxy in
            let (totalWeight, reservedLength) = calculateTotalWeight(for: column.items, in: proxy)
            let weightsAvailableLength = proxy.size.height - reservedLength

            LazyHGrid(
                rows: column.items.map { item in
                    switch item.length {
                    case let .fixed(length):
                        .init(
                            .fixed(length.points(screenSize: screenSize.height)),
                            spacing: column.spacing,
                            alignment: .from(horizontal: item.horizontalAlignment,
                                             vertical: item.verticalAlignment)
                        )
                    case let .weight(weight):
                        .init(
                            .fixed((Double(weight) / Double(totalWeight)) * weightsAvailableLength),
                            spacing: column.spacing,
                            alignment: .from(horizontal: item.horizontalAlignment,
                                             vertical: item.verticalAlignment)
                        )
                    }
                },
                spacing: 0.0,
                content: {
                    ForEach(0 ..< column.items.count, id: \.self) { idx in
                        AdaptyUIElementView(column.items[idx].content)
                    }
                }
            )
            .onGeometrySizeChange { contentsSize = $0 }
        }
        .frame(width: contentsSize.width)
    }
}

#if DEBUG

@available(iOS 15.0, *)
#Preview {
    ScrollView {
        VStack {
            Text("Top")

            AdaptyUIColumnView(
                AdaptyUI.Column.create(
                    spacing: 10.0,
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
            .frame(height: 500) // Important!!!
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
