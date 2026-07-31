//
//  AdaptyUIFlexStackView_Layout.swift
//  AdaptyUIBuilder
//

#if canImport(UIKit)

import SwiftUI

/// `Layout`-based counterpart of `AdaptyUIFlexStackView`, selected by the
/// `#available` branch in `AdaptyUIElementView`. The original view is untouched
/// and keeps serving iOS 15 / macOS 12.
///
/// The items are handed to `AdaptyUIFlexStackLayout` directly instead of going
/// through `asStack(direction:)` + `AdaptyUIStackView`: the direction is no longer
/// known when the body is built, so it cannot pick between `HStack` and `VStack`
/// there. The layout picks the axis from the proposal and then delegates to
/// `HStackLayout` / `VStackLayout`, which is what `AdaptyUIStackView` would have
/// produced anyway — `Spacer` items included.
///
/// Gone with the `GeometryReader`: `@State availableSize`, `@State direction`,
/// `@State contentsSize`, the `.frame(minWidth:minHeight:)` floor and the manual
/// reset of that floor on every flip.
@available(iOS 16.0, macOS 13.0, *)
@MainActor
struct AdaptyUIFlexStackView_Layout<ScreenHolderContent: View>: View {
    @Environment(\.adaptyScreenSize)
    private var screenSize: CGSize
    @Environment(\.adaptyInterfaceOrientation)
    private var orientation: VC.Orientation
    @Environment(\.layoutDirection)
    private var layoutDirection: LayoutDirection

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
        AdaptyUIFlexStackLayout(
            condition: flexStack.condition,
            matchedDirection: flexStack.direction,
            orientation: orientation,
            screenSize: screenSize,
            horizontalAlignment: flexStack.horizontalAlignment.swiftuiValue(with: layoutDirection),
            verticalAlignment: flexStack.verticalAlignment.swiftuiValue,
            horizontalSpacing: CGFloat(flexStack.horizontalSpacing),
            verticalSpacing: CGFloat(flexStack.verticalSpacing)
        ) {
            ForEach(0 ..< flexStack.items.count, id: \.self) { index in
                switch flexStack.items[index] {
                case let .space(count):
                    if count > 0 {
                        ForEach(0 ..< count, id: \.self) { _ in
                            Spacer()
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
        .adaptyAnimateAxisFlip(
            flexStack.transition,
            orientation: orientation,
            screenSize: screenSize
        )
    }
}

@available(iOS 16.0, macOS 13.0, *)
extension View {
    /// Animates a direction flip with the element's own `transition`.
    ///
    /// The resolved direction lives inside the layout now, so there is no state
    /// write to wrap in `withAnimation` the way the old views did. What can be keyed
    /// on instead is the **trigger**: `orientation` and `screenSize` are read from
    /// the environment here in the body, so a flip caused by either is animated with
    /// the configured duration.
    ///
    /// A flip caused by `available_*` — the parent offering a different size — has no
    /// such trigger: the layout learns about it from the proposal, which the body
    /// never sees. Those flips interpolate only if whatever resized the parent was
    /// itself animated, which is also all the old implementation managed: its
    /// size-driven `recompute` reset the measured floor outside the animation, and
    /// the resulting jump swallowed the transition.
    @ViewBuilder
    func adaptyAnimateAxisFlip(
        _ transition: VC.Transition?,
        orientation: VC.Orientation,
        screenSize: CGSize
    ) -> some View {
        if let flipAnimation = transition?.swiftUIAnimation {
            animation(flipAnimation, value: orientation)
                .animation(flipAnimation, value: screenSize)
        } else {
            self
        }
    }
}

#endif
