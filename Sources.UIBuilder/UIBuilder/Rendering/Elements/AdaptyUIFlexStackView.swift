//
//  AdaptyUIFlexStackView.swift
//  AdaptyUIBuilder
//

#if canImport(UIKit)

import SwiftUI

/// Renders a `FlexStack`: resolves the environment into numbers and leaves the
/// choice of direction to `AdaptyUIFlexStackLayout`, which sees the proposal.
@MainActor
@available(iOS 16.0, macOS 13.0, visionOS 1.0, *)
struct AdaptyUIFlexStackView<ScreenHolderContent: View>: View {
    @Environment(\.adaptyScreenSize) private var screenSize: CGSize
    @Environment(\.adaptyInterfaceOrientation) private var orientation: VC.Orientation
    @Environment(\.adaptyHuggedAxes) private var huggedAxes: Axis.Set
    @Environment(\.layoutDirection) private var layoutDirection: LayoutDirection

    private let flexStack: VC.FlexStack
    private let screenHolderBuilder: () -> ScreenHolderContent

    init(
        _ flexStack: VC.FlexStack,
        @ViewBuilder screenHolderBuilder: @escaping () -> ScreenHolderContent
    ) {
        self.flexStack = flexStack
        self.screenHolderBuilder = screenHolderBuilder
    }

    var body: some View {
        if let animation = flexStack.transition?.swiftUIAnimation {
            // The direction is chosen inside the layout pass, where no animation
            // can be started. A reorientation follows the screen almost always — a
            // rotation, a resized window — so the transition animates the changes
            // these bring.
            stack
                .animation(animation, value: screenSize)
                .animation(animation, value: orientation)
        } else {
            stack
        }
    }

    private var stack: some View {
        AdaptyUIFlexStackLayout(
            conditions: flexStack.condition,
            direction: flexStack.direction,
            screenSize: screenSize,
            orientation: orientation,
            huggedAxes: huggedAxes,
            horizontalSpacing: flexStack.horizontalSpacing.cgFloatValue,
            verticalSpacing: flexStack.verticalSpacing.cgFloatValue,
            verticalAnchor: flexStack.verticalAlignment.anchorFraction,
            horizontalAnchor: flexStack.horizontalAlignment.anchorFraction(with: layoutDirection)
        ) {
            // The subviews a native stack would get: elements as they render, one
            // `Spacer` per unit of `space`.
            ForEach(0 ..< flexStack.items.count, id: \.self) { idx in
                switch flexStack.items[idx] {
                case let .space(count):
                    if count > 0 {
                        ForEach(0 ..< count, id: \.self) { _ in
                            Spacer().layoutValue(key: AdaptyUIFlexStackSpaceKey.self, value: true)
                        }
                    }
                case let .element(element):
                    AdaptyUIElementView(
                        element,
                        screenHolderBuilder: screenHolderBuilder
                    )
                }
            }
        }
    }
}

#endif
