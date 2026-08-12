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
    /// Natural size of the current stack. Used as a floor on the greedy
    /// GeometryReader so it can't collapse below its content when the parent
    /// proposes nil on an axis (e.g. the scroll axis of a ScrollView).
    @State private var contentsSize: CGSize = .zero

    private func computedDirection(orientation: VC.Orientation) -> VC.Flex.Direction {
        let match = VC.Condition.evaluate(
            flexStack.condition,
            available: availableSize,
            screen: screenSize,
            orientation: orientation
        )
        return match ? flexStack.direction : flexStack.direction.opposite
    }

    var body: some View {
        GeometryReader { proxy in
            AdaptyUIStackView(
                flexStack.asStack(direction: direction),
                screenHolderBuilder: screenHolderBuilder
            )
            .onGeometrySizeChange { contentsSize = $0 }
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
        // Floor the greedy reader at the content size: `proxy.size` still equals the
        // parent proposal when bounded (so the condition reads it), but the view can't
        // collapse to ~10pt when the parent proposes nil (a ScrollView scroll axis).
        .frame(minWidth: contentsSize.width, minHeight: contentsSize.height)
    }

    private func recompute(orientation: VC.Orientation) {
        let newDirection = computedDirection(orientation: orientation)
        guard newDirection != direction else { return }
        // Drop the stale floor so the flipped stack re-measures from scratch;
        // otherwise the previous axis' size would over-size the new orientation.
        contentsSize = .zero
        if let transition = flexStack.transition {
            withAnimation(transition.swiftUIAnimation) { direction = newDirection }
        } else {
            direction = newDirection
        }
    }
}

#endif
