//
//  AdaptyUIFlexView.swift
//  AdaptyUIBuilder
//

#if canImport(UIKit)

import SwiftUI

@MainActor
struct AdaptyUIFlexView<ScreenHolderContent: View>: View {
    @Environment(\.adaptyScreenSize) private var screenSize: CGSize
    @Environment(\.adaptyInterfaceOrientation) private var orientation: VC.Orientation

    private let flex: VC.Flex
    private let screenHolderBuilder: () -> ScreenHolderContent

    init(
        _ flex: VC.Flex,
        @ViewBuilder screenHolderBuilder: @escaping () -> ScreenHolderContent
    ) {
        self.flex = flex
        self.screenHolderBuilder = screenHolderBuilder
    }

    @State private var availableSize: CGSize = .zero
    @State private var direction: VC.Flex.Direction = .vertical
    /// Intrinsic height of the content in row mode (FlexRowView reports it via
    /// fixedSize). Pinned onto the greedy GeometryReader so a horizontal flex hugs
    /// its content height instead of collapsing to ~10pt when the parent proposes
    /// nil height (a ScrollView scroll axis). Column mode stays greedy.
    @State private var contentHeight: CGFloat = 0

    private func computedDirection(orientation: VC.Orientation) -> VC.Flex.Direction {
        let match = VC.Condition.evaluate(
            flex.condition,
            available: availableSize,
            screen: screenSize,
            orientation: orientation
        )
        return match ? flex.direction : flex.direction.opposite
    }

    var body: some View {
        GeometryReader { proxy in
            content(available: proxy.size)
                .onGeometrySizeChange { contentHeight = $0.height }
                .onAppear {
                    availableSize = proxy.size
                    direction = computedDirection(orientation: orientation)
                }
                .onChange(of: proxy.size) { newSize in
                    guard newSize != availableSize else { return }
                    availableSize = newSize
                    recompute(orientation: orientation)
                }
                .onChange(of: screenSize) { _ in recompute(orientation: orientation) }
                .onChange(of: orientation) { newOrientation in recompute(orientation: newOrientation) }
        }
        // Row mode hugs its cross axis (height): FlexRowView reports an intrinsic
        // height via fixedSize, pinned here so the greedy GeometryReader's slot
        // matches the content instead of collapsing to ~10pt inside a ScrollView.
        // Column mode stays greedy (nil height) — its weights need the proposal.
        .frame(height: direction == .horizontal ? contentHeight : nil)
    }

    @ViewBuilder
    private func content(available: CGSize) -> some View {
        switch direction {
        case .horizontal:
            let row = flex.asRow
            switch row.width {
            case .legacy:
                AdaptyUIRowView(row, screenHolderBuilder: screenHolderBuilder)
            case .hug, .fill:
                AdaptyUIFlexRowView(row, externalSize: available, screenHolderBuilder: screenHolderBuilder)
            }
        case .vertical:
            let column = flex.asColumn
            switch column.height {
            case .legacy:
                AdaptyUIColumnView(column, screenHolderBuilder: screenHolderBuilder)
            case .hug, .fill:
                AdaptyUIFlexColumnView(column, externalSize: available, screenHolderBuilder: screenHolderBuilder)
            }
        }
    }

    private func recompute(orientation: VC.Orientation) {
        let newDirection = computedDirection(orientation: orientation)
        guard newDirection != direction else { return }
        if let transition = flex.transition {
            withAnimation(transition.swiftUIAnimation) { direction = newDirection }
        } else {
            direction = newDirection
        }
    }
}

#endif
