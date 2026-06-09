//
//  AdaptyUIFlexStackView.swift
//  AdaptyUIBuilder
//

#if canImport(UIKit)

import SwiftUI

@MainActor
struct AdaptyUIFlexStackView<ScreenHolderContent: View>: View {
    @Environment(\.adaptyScreenSize) private var screenSize: CGSize
    @Environment(\.adaptyInterfaceOrientation) private var orientation: VC.Orientation

    private let flexStack: VC.FlexStack
    private let screenHolderBuilder: () -> ScreenHolderContent

    init(
        _ flexStack: VC.FlexStack,
        @ViewBuilder screenHolderBuilder: @escaping () -> ScreenHolderContent
    ) {
        self.flexStack = flexStack
        self.screenHolderBuilder = screenHolderBuilder
    }

    @State private var availableSize: CGSize = .zero
    @State private var direction: VC.Flex.Direction = .vertical

    private var computedDirection: VC.Flex.Direction {
        let match = VC.Condition.evaluate(
            flexStack.condition,
            available: availableSize,
            screen: screenSize,
            orientation: orientation
        )
        return match ? flexStack.direction : flexStack.direction.opposite
    }

    var body: some View {
        AdaptyUIStackView(
            flexStack.asStack(direction: direction),
            screenHolderBuilder: screenHolderBuilder
        )
        .onAppear { direction = computedDirection }
        .onGeometrySizeChange { newSize in
            guard newSize != availableSize else { return }
            availableSize = newSize
            recompute()
        }
        .onChange(of: screenSize) { _ in recompute() }
        .onChange(of: orientation) { _ in recompute() }
    }

    private func recompute() {
        let newDirection = computedDirection
        guard newDirection != direction else { return }
        if let transition = flexStack.transition {
            withAnimation(transition.swiftUIAnimation) { direction = newDirection }
        } else {
            direction = newDirection
        }
    }
}

#endif
