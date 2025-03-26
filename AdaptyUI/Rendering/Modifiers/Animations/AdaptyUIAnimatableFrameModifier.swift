//
//  AdaptyUIFixedFrameModifier.swift
//
//
//  Created by Aleksey Goncharov on 16.05.2024.
//

#if canImport(UIKit)

import Adapty
import SwiftUI

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
struct AdaptyUIAnimatableFrameModifier: ViewModifier {
    private let box: VC.Box
    private let animations: [AdaptyViewConfiguration.Animation]?

    @State private var animatedWidth: CGFloat?
    @State private var animatedHeight: CGFloat?

    @Environment(\.adaptyScreenSize)
    private var screenSize: CGSize
    @Environment(\.adaptySafeAreaInsets)
    private var safeArea: EdgeInsets
    @Environment(\.layoutDirection)
    private var layoutDirection: LayoutDirection

    init(
        box: VC.Box,
        animations: [AdaptyViewConfiguration.Animation]?
    ) {
        self.box = box
        self.animations = animations
    }

    private func resolveDimensions() -> (width: CGFloat?, height: CGFloat?) {
        let resolvedWidth: CGFloat?
        let resolvedHeight: CGFloat?

        switch (box.width, box.height) {
        case let (.fixed(w), .fixed(h)):
            resolvedWidth = animatedWidth ?? w.points(screenSize: screenSize.width, safeAreaStart: safeArea.leading, safeAreaEnd: safeArea.trailing)
            resolvedHeight = animatedHeight ?? h.points(screenSize: screenSize.height, safeAreaStart: safeArea.top, safeAreaEnd: safeArea.bottom)
        case let (.fixed(w), _):
            resolvedWidth = animatedWidth ?? w.points(screenSize: screenSize.width, safeAreaStart: safeArea.leading, safeAreaEnd: safeArea.trailing)
            resolvedHeight = animatedHeight
        case let (_, .fixed(h)):
            resolvedWidth = animatedWidth
            resolvedHeight = animatedHeight ?? h.points(screenSize: screenSize.height, safeAreaStart: safeArea.top, safeAreaEnd: safeArea.bottom)
        default:
            resolvedWidth = animatedWidth
            resolvedHeight = animatedHeight
        }

        return (resolvedWidth, resolvedHeight)
    }

    func body(content: Content) -> some View {
        let (width, height) = resolveDimensions()

        if width != nil || height != nil {
            let alignment = Alignment.from(
                horizontal: box.horizontalAlignment.swiftuiValue(with: layoutDirection),
                vertical: box.verticalAlignment.swiftuiValue
            )

            content
                .frame(
                    width: width,
                    height: height,
                    alignment: alignment
                )
                .onAppear { startAnimations() }
        } else {
            content.onAppear { startAnimations() }
        }
    }

    private func startAnimations() {
        guard let animations, !animations.isEmpty else { return }

        for animation in animations {
            switch animation {
            case let .width(timeline, value):
                startValueAnimation(
                    timeline,
                    interpolator: value.interpolator,
                    from: value.start,
                    to: value.end
                ) {
                    self.animatedWidth = $0.points(
                        screenSize: screenSize.width,
                        safeAreaStart: safeArea.leading,
                        safeAreaEnd: safeArea.trailing
                    )
                }
            case let .height(timeline, value):
                startValueAnimation(
                    timeline,
                    interpolator: value.interpolator,
                    from: value.start,
                    to: value.end
                ) {
                    self.animatedHeight = $0.points(
                        screenSize: self.screenSize.height,
                        safeAreaStart: self.safeArea.top,
                        safeAreaEnd: self.safeArea.bottom
                    )
                }
            default:
                break
            }
        }
    }

    private func startValueAnimation<Value>(
        _ timeline: AdaptyViewConfiguration.Animation.Timeline,
        interpolator: AdaptyViewConfiguration.Animation.Interpolator,
        from start: Value,
        to end: Value,
        updateBlock: (Value) -> Void
    ) {
        updateBlock(start)

        let (animation, _) = Animation.customIgnoringElasticAndBounce(
            timeline: timeline,
            interpolator: interpolator
        )

        withAnimation(animation) {
            updateBlock(end)
        }
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
extension View {
    @ViewBuilder
    func animatableFrame(
        box: VC.Box,
        animations: [AdaptyViewConfiguration.Animation]?
    ) -> some View {
        modifier(
            AdaptyUIAnimatableFrameModifier(
                box: box,
                animations: animations
            )
        )
    }
}

#endif
