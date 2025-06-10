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

    @State private var animationTokens = Set<AdaptyUIAnimationToken>()

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
                .onDisappear {
                    animationTokens.forEach { $0.invalidate() }
                    animationTokens.removeAll()
                }
        } else {
            content
                .onAppear { startAnimations() }
                .onDisappear {
                    animationTokens.forEach { $0.invalidate() }
                    animationTokens.removeAll()
                }
        }
    }

    private func startAnimations() {
        guard let animations, !animations.isEmpty else { return }

        var tokens = Set<AdaptyUIAnimationToken>()

        for animation in animations {
            switch animation {
            case let .box(timeline, value):
                if let widthValue = value.width {
                    animatedWidth = widthValue.start.points(.horizontal, screenSize, safeArea)

                    tokens.insert(
                        timeline.animate(
                            from: widthValue.start,
                            to: widthValue.end,
                            updateBlock: {
                                self.animatedWidth = $0.points(.horizontal, screenSize, safeArea)
                            }
                        )
                    )
                }

                if let heightValue = value.height {
                    animatedHeight = heightValue.start.points(.vertical, screenSize, safeArea)

                    tokens.insert(
                        timeline.animate(
                            from: heightValue.start,
                            to: heightValue.end,
                            updateBlock: {
                                self.animatedHeight = $0.points(.vertical, screenSize, safeArea)
                            }
                        )
                    )
                }
            default:
                break
            }
        }

        animationTokens = tokens
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
