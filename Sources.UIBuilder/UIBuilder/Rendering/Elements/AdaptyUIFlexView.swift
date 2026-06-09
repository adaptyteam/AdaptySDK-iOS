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

    private var computedDirection: VC.Flex.Direction {
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
                .onAppear {
                    availableSize = proxy.size
                    direction = computedDirection
                }
                .onChange(of: proxy.size) { newSize in
                    guard newSize != availableSize else { return }
                    availableSize = newSize
                    recompute()
                }
                .onChange(of: screenSize) { _ in recompute() }
                .onChange(of: orientation) { _ in recompute() }
        }
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

    private func recompute() {
        let newDirection = computedDirection
        guard newDirection != direction else { return }
        if let transition = flex.transition {
            withAnimation(transition.swiftUIAnimation) { direction = newDirection }
        } else {
            direction = newDirection
        }
    }
}

#endif
