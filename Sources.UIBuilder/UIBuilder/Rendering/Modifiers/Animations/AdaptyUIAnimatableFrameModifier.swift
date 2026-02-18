//
//  AdaptyUIFixedFrameModifier.swift
//
//
//  Created by Aleksey Goncharov on 16.05.2024.
//


import SwiftUI

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
typealias FrameAnimationValue = (
    width: VC.Unit?,
    height: VC.Unit?
)

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
typealias FrameAnimationRange = (
    start: FrameAnimationValue,
    end: FrameAnimationValue
)

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
struct AdaptyUIAnimatableFrameModifier: ViewModifier {
    private let box: VC.Box
    private let animations: [VC.Animation]?

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
        animations: [VC.Animation]?
    ) {
        self.box = box
        self.animations = animations
    }

    private func resolveDimensions() -> (width: CGFloat?, height: CGFloat?) {
        let resolvedWidth: CGFloat?
        let resolvedHeight: CGFloat?

        switch (box.width, box.height) {
        case (.fixed(let w), .fixed(let h)):
            resolvedWidth = animatedWidth ?? w.points(screenSize: screenSize.width, safeAreaStart: safeArea.leading, safeAreaEnd: safeArea.trailing)
            resolvedHeight = animatedHeight ?? h.points(screenSize: screenSize.height, safeAreaStart: safeArea.top, safeAreaEnd: safeArea.bottom)
        case (.fixed(let w), _):
            resolvedWidth = animatedWidth ?? w.points(screenSize: screenSize.width, safeAreaStart: safeArea.leading, safeAreaEnd: safeArea.trailing)
            resolvedHeight = animatedHeight
        case (_, .fixed(let h)):
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
            case .box(let timeline, let value):
                let frameAnimationRange: FrameAnimationRange?

                switch (value.width, value.height) {
                case (.some(let w), .some(let h)):
                    frameAnimationRange = (
                        start: (width: w.start, height: h.start),
                        end: (width: w.end, height: h.end)
                    )
                case (.none, .some(let h)):
                    frameAnimationRange = (
                        start: (width: nil, height: h.start),
                        end: (width: nil, height: h.end)
                    )
                case (.some(let w), .none):
                    frameAnimationRange = (
                        start: (width: w.start, height: nil),
                        end: (width: w.end, height: nil)
                    )
                case (.none, .none):
                    frameAnimationRange = nil
                }

                guard let range = frameAnimationRange else { break }

                if let startWidth = range.start.width {
                    animatedWidth = startWidth.points(.horizontal, screenSize, safeArea)
                }

                if let startHeight = range.start.height {
                    animatedWidth = startHeight.points(.horizontal, screenSize, safeArea)
                }

                tokens.insert(
                    timeline.animate(
                        from: range.start,
                        to: range.end,
                        updateBlock: { v in
                            if let currentWidth = v.width {
                                animatedWidth = currentWidth.points(.horizontal, screenSize, safeArea)
                            }

                            if let currentHeight = v.height {
                                animatedHeight = currentHeight.points(.horizontal, screenSize, safeArea)
                            }
                        }
                    )
                )

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
        animations: [VC.Animation]?
    ) -> some View {
        modifier(
            AdaptyUIAnimatableFrameModifier(
                box: box,
                animations: animations
            )
        )
    }
}
