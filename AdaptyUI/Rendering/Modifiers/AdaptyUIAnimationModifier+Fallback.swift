//
//  File.swift
//  Adapty
//
//  Created by Alexey Goncharov on 3/24/25.
//

#if canImport(UIKit)

import Adapty
import SwiftUI

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
struct AdaptyUIAnimatablePropertiesFallbackModifier: ViewModifier {
    private let animations: [AdaptyViewConfiguration.Animation]

    init(_ properties: VC.Element.Properties) {
        self.animations = properties.onAppear
    }

    func applyingAnimation(content: AnyView, animation: AdaptyViewConfiguration.Animation) -> AnyView {
        switch animation {
        case let .offset(timeline, value):
            AnyView(
                content.modifier(
                    AdaptyUIAnimatableOffsetModifier(
                        timeline: timeline,
                        interpolator: value.interpolator,
                        startValue: value.start,
                        endValue: value.end
                    )
                )
            )
        default:
            content
        }
    }

    func body(content: Content) -> some View {
        var result = AnyView(content)

        for animation in animations {
            result = applyingAnimation(
                content: result,
                animation: animation
            )
        }

        return result
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
struct AdaptyUIAnimatableOffsetModifier: ViewModifier {
    private let timeline: AdaptyViewConfiguration.Animation.Timeline
    private let startValue: AdaptyViewConfiguration.Offset
    private let endValue: AdaptyViewConfiguration.Offset

    private let animation: Animation
    private let functor: (Double) -> Double

    init(
        timeline: AdaptyViewConfiguration.Animation.Timeline,
        interpolator: AdaptyViewConfiguration.Animation.Interpolator,
        startValue: AdaptyViewConfiguration.Offset,
        endValue: AdaptyViewConfiguration.Offset
    ) {
        self.timeline = timeline
        self.startValue = startValue
        self.endValue = endValue

        (self.animation, self.functor) = Animation.createFallback(
            timeline: timeline,
            interpolator: interpolator
        )
    }

    @State private var progress = 0.0

    @Environment(\.adaptyScreenSize)
    private var screenSize: CGSize
    @Environment(\.adaptySafeAreaInsets)
    private var safeArea: EdgeInsets

    func body(content: Content) -> some View {
        content
            .modifier(
                AdaptyUIAnimatableOffsetCustomInterpolator(
                    startOffset: .init(width: startValue.x.points(.horizontal, screenSize, safeArea),
                                       height: startValue.y.points(.vertical, screenSize, safeArea)),
                    endOffset: .init(width: endValue.x.points(.horizontal, screenSize, safeArea),
                                     height: endValue.y.points(.vertical, screenSize, safeArea)),
                    progress: progress,
                    functor: functor
                )
            )
            .onAppear {
                startAnimation()
            }
    }

    private func startAnimation() {
        withAnimation(animation) {
            progress = 1.0
        }
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
struct AdaptyUIAnimatableOffsetCustomInterpolator: AnimatableModifier {
    private let startOffset: CGSize
    private let endOffset: CGSize

    private let functor: (Double) -> Double

    init(
        startOffset: CGSize,
        endOffset: CGSize,
        progress: Double,
        functor: @escaping (Double) -> Double
    ) {
        self.startOffset = startOffset
        self.endOffset = endOffset
        self.progress = progress
        self.functor = functor
    }

    private var progress: Double

    nonisolated var animatableData: Double {
        get { progress }
        set { progress = newValue }
    }

    func body(content: Content) -> some View {
        let xOffset = startOffset.width + (endOffset.width - startOffset.width) * progress
        let yOffset = startOffset.height + (endOffset.height - startOffset.height) * functor(progress)

        return content
            .offset(.init(width: xOffset, height: yOffset))
    }
}

#endif
