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
    @Environment(\.adaptyUnspecifiedProposalAxes)
    private var unspecifiedProposalAxes: Axis.Set

    private let row: VC.Row
    private let externalSize: CGSize?
    private let screenHolderBuilder: () -> ScreenHolderContent

    init(
        _ row: VC.Row,
        externalSize: CGSize? = nil,
        @ViewBuilder screenHolderBuilder: @escaping () -> ScreenHolderContent
    ) {
        self.row = row
        self.externalSize = externalSize
        self.screenHolderBuilder = screenHolderBuilder
    }

    private func calculateTotalWeight(
        for items: [VC.GridItem]
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
        weightsAvailableLength: CGFloat?
    ) -> CGFloat? {
        switch item.length {
        case let .fixed(length):
            length.points(
                screenSize: screenSize.width,
                safeAreaStart: safeArea.leading,
                safeAreaEnd: safeArea.trailing
            )
        case let .weight(weight):
            weightsAvailableLength.map {
                totalWeight > 0 ? (Double(weight) / Double(totalWeight)) * $0 : 0
            }
        }
    }

    @State private var measuredSize: CGSize = .zero

    @ViewBuilder
    var body: some View {
        if let drawAsStack = row.drawAsStack {
            stackBody(drawAsStack)
        } else {
            switch row.width {
            case .hug:
                fixedBody
            case .fill, .legacy:
                weightedBody
            }
        }
    }

    /// A native HStack: it hugs its content on both axes and drops the items' weights
    /// — that is what `draw_as_stack` asks for, so `width` stays unused here.
    private func stackBody(_ params: VC.StackParams) -> some View {
        HStack(alignment: params.verticalAlignment.swiftuiValue, spacing: row.spacing) {
            ForEach(0 ..< row.items.count, id: \.self) { idx in
                AdaptyUIElementView(
                    row.items[idx].content,
                    screenHolderBuilder: screenHolderBuilder
                )
            }
        }
    }

    private var fixedBody: some View {
        HStack(spacing: row.spacing) {
            ForEach(0 ..< row.items.count, id: \.self) { idx in
                let item = row.items[idx]

                AdaptyUIElementView(
                    item.content,
                    screenHolderBuilder: screenHolderBuilder
                )
                .frame(
                    width: itemWidth(
                        item,
                        totalWeight: 0,
                        weightsAvailableLength: 0
                    ),
                    alignment: Alignment.from(
                        horizontal: item.horizontalAlignment.swiftuiValue(with: layoutDirection),
                        vertical: item.verticalAlignment.swiftuiValue
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
        .fixedSize(horizontal: false, vertical: true)
    }

    private var weightedBody: some View {
        GeometryReader { proxy in
            weightedContent(availableWidth: externalSize?.width
                ?? (unspecifiedProposalAxes.contains(.horizontal) ? nil : proxy.size.width))
        }
        // The reader is greedy on both axes; the row hugs its content vertically, so
        // the measured height is handed back as the row's own height — the same shape
        // `AdaptyUIRowView` uses. Height does not ratchet: it is measured on the
        // content, which does not depend on the height proposed to it.
        .frame(height: measuredSize.height)
    }

    /// - Parameter availableWidth: width to distribute among the weighted items, or
    ///   nil while it is genuinely unknown — under a `shrink` box, and on the first
    ///   frame. Weighted items then keep their natural width instead of collapsing to
    ///   width 0, where texts vanish and their ideal height explodes.
    ///
    ///   It comes from the live reader rather than from `measuredSize`: the HStack
    ///   below is measured *into* `measuredSize`, so feeding that back as the width to
    ///   divide made the row grow-only. Items got hard widths summing to the old
    ///   width, the HStack could not shrink below them, and the measurement never
    ///   fell — a narrower proposal simply spilled past the edge.
    @ViewBuilder
    private func weightedContent(availableWidth: CGFloat?) -> some View {
        let (totalWeight, reservedLength) = calculateTotalWeight(for: row.items)
        let weightsAvailableLength: CGFloat? = availableWidth.map { max(0, $0 - reservedLength) }

        HStack(spacing: row.spacing) {
            ForEach(0 ..< row.items.count, id: \.self) { idx in
                let item = row.items[idx]

                AdaptyUIElementView(
                    item.content,
                    screenHolderBuilder: screenHolderBuilder
                )
                .frame(
                    width: itemWidth(
                        item,
                        totalWeight: totalWeight,
                        weightsAvailableLength: weightsAvailableLength
                    ),
                    alignment: Alignment.from(
                        horizontal: item.horizontalAlignment.swiftuiValue(with: layoutDirection),
                        vertical: item.verticalAlignment.swiftuiValue
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
        .fixedSize(horizontal: false, vertical: true)
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .onGeometrySizeChange { measuredSize = $0 }
    }
}

#endif
