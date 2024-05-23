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
struct GeometrySizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}

@available(iOS 15.0, *)
struct AdaptyUIGeometrySizeObserver: ViewModifier {
    var onChange: (CGSize) -> Void

    init(_ onChange: @escaping (CGSize) -> Void) {
        self.onChange = onChange
    }

    func body(content: Content) -> some View {
        content
            .background {
                GeometryReader { proxy in
                    Color
                        .clear
                        .preference(key: GeometrySizePreferenceKey.self, value: proxy.size)
                        .onPreferenceChange(GeometrySizePreferenceKey.self) { onChange($0) }
                }
            }
    }
}

@available(iOS 15.0, *)
extension View {
    func onGeometrySizeChange(perform action: @escaping (CGSize) -> Void) -> some View {
        modifier(AdaptyUIGeometrySizeObserver(action))
    }
}

@available(iOS 15.0, *)
struct AdaptyUIRowView: View {
    @Environment(\.adaptyScreenSize)
    private var screenSize: CGSize

    var row: AdaptyUI.Row

    init(_ row: AdaptyUI.Row) {
        self.row = row
    }

    private func calculateTotalWeight(for items: [AdaptyUI.RowOrColumnItem],
                                      in proxy: GeometryProxy) -> (Int, CGFloat)
    {
        var totalWeight = 0
        var reservedLength: CGFloat = 0.0

        for item in items {
            switch item {
            case let .fixed(length, content):
                reservedLength += length.points(screenSize: screenSize.width)
            case let .flexible(weight, content):
                totalWeight += weight
            }
        }

        if row.spacing > 0 {
            reservedLength += CGFloat(row.spacing * Double(items.count - 1))
        }

        return (totalWeight, reservedLength)
    }

    @State private var contentsSize = CGSize(width: CGFloat.infinity, height: CGFloat.infinity)

    var body: some View {
        GeometryReader { proxy in
            let (totalWeight, reservedLength) = calculateTotalWeight(for: row.items, in: proxy)
            let weightsAvailableLength = proxy.size.width - reservedLength

            LazyVGrid(columns: row.items.map { item in
                switch item {
                case let .fixed(length, content):
                    return .init(.fixed(length.points(screenSize: screenSize.width)),
                                 spacing: row.spacing,
                                 alignment: .center) // TODO: apply row alignment
                case let .flexible(weight, content):
                    return .init(.fixed((Double(weight) / Double(totalWeight)) * weightsAvailableLength),
                                 spacing: row.spacing,
                                 alignment: .topTrailing) // TODO: apply row alignment
                }
            },
            spacing: 0.0,
            content: {
                ForEach(0 ..< row.items.count, id: \.self) { idx in
                    AdaptyUIElementView(row.items[idx].content)
                }
            })
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
                    verticalAlignment: .bottom,
                    spacing: 6.0,
                    items: [
//                        .flexible(weight: 1, content: .text(.testBodyShort, nil)),
//                        .fixed(length: .point(32), content: .text(.init([
//                            .text("Hello world! Hello world! Hello world!", .testBody),
//                        ]), nil)),

                        .flexible(weight: 1, content: .text(.testBodyShort, nil)),
                        .flexible(weight: 2, content: .text(.testBodyShort, nil)),
                        .flexible(weight: 2, content: .text(.testBodyShort, nil)),
//
//                        .fixed(length: .point(32), content: .text(.init([
//                            .text("Hellllo world! Hello world! Hello world!", .testBody),
//                        ]), nil)),
                    ]
                )
            )
            .background(Color.green)

            Text("Bottom")
        }
        .withScreenSize(.init(width: 320, height: 240))
    }
}

#endif

#endif
