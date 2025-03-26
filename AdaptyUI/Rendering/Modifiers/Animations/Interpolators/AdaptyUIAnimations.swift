//
//  AdaptyUIAnimations.swift
//
//
//  Created by Aleksey Goncharov on 21.03.2025.
//

#if canImport(UIKit)

import Adapty
import SwiftUI

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
extension AdaptyViewConfiguration.Animation.Interpolator {
    @available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, visionOS 1.0, *)
    func animation(duration: TimeInterval) -> Animation {
        switch self {
        case .easeInOut: .easeInOut(duration: duration)
        case .easeIn: .easeIn(duration: duration)
        case .easeOut: .easeOut(duration: duration)
        case .linear: .linear(duration: duration)
        case .cubicBezier(let x1, let y1, let x2, let y2): .timingCurve(x1, y1, x2, y2, duration: duration)
        case .easeInElastic: .adaptyCustomEaseInElastic(duration: duration)
        case .easeOutElastic: .adaptyCustomEaseOutElastic(duration: duration)
        case .easeInOutElastic: .adaptyCustomEaseInOutElastic(duration: duration)
        case .easeInBounce: .adaptyCustomEaseInBounce(duration: duration)
        case .easeOutBounce: .adaptyCustomEaseOutBounce(duration: duration)
        case .easeInOutBounce: .adaptyCustomEaseInOutBounce(duration: duration)
        }
    }

    func animationIgnoringElasticAndBounce(duration: TimeInterval) -> Animation {
        switch self {
        case .easeInOut: .easeInOut(duration: duration)
        case .easeIn: .easeIn(duration: duration)
        case .easeOut: .easeOut(duration: duration)
        case .cubicBezier(let x1, let y1, let x2, let y2): .timingCurve(x1, y1, x2, y2, duration: duration)
        default: .linear(duration: duration)
        }
    }

    func customFunctor() -> (Double) -> Double {
        switch self {
        case .easeInElastic: AdaptyUICustomAnimationFunctions.easeInElastic(_:)
        case .easeOutElastic: AdaptyUICustomAnimationFunctions.easeOutElastic(_:)
        case .easeInOutElastic: AdaptyUICustomAnimationFunctions.easeInOutElastic(_:)
        case .easeInBounce: AdaptyUICustomAnimationFunctions.easeInBounce(_:)
        case .easeOutBounce: AdaptyUICustomAnimationFunctions.easeOutBounce(_:)
        case .easeInOutBounce: AdaptyUICustomAnimationFunctions.easeInOutBounce(_:)
        default: { $0 }
        }
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
extension Animation {
    func withTimeline(_ timeline: AdaptyViewConfiguration.Animation.Timeline) -> Animation {
        guard let type = timeline.repeatType else { return self }

        switch type {
        case .reverse:
            if let count = timeline.repeatMaxCount {
                return delay(timeline.repeatDelay)
                    .repeatCount(count, autoreverses: true)
            } else {
                return delay(timeline.repeatDelay)
                    .repeatForever(autoreverses: true)
            }
        case .restart:
            if let count = timeline.repeatMaxCount {
                return delay(timeline.repeatDelay)
                    .repeatCount(count, autoreverses: false)
            } else {
                return delay(timeline.repeatDelay)
                    .repeatForever(autoreverses: false)
            }
        }
    }

    @available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, visionOS 1.0, *)
    static func custom(
        timeline: AdaptyViewConfiguration.Animation.Timeline,
        interpolator: AdaptyViewConfiguration.Animation.Interpolator
    ) -> Animation {
        interpolator
            .animation(duration: timeline.duration)
            .withTimeline(timeline)
            .delay(timeline.startDelay)
    }

    static func customFallback(
        timeline: AdaptyViewConfiguration.Animation.Timeline,
        interpolator: AdaptyViewConfiguration.Animation.Interpolator
    ) -> (Animation, (Double) -> Double) {
        (
            interpolator
                .animationIgnoringElasticAndBounce(duration: timeline.duration)
                .withTimeline(timeline)
                .delay(timeline.startDelay),
            interpolator.customFunctor()
        )
    }

    static func customFallback(
        animation: AdaptyViewConfiguration.Animation
    ) -> (Animation, (Double) -> Double) {
        let (timeline, interpolator) = animation.getAnimationProperties()

        return Animation.customFallback(
            timeline: timeline,
            interpolator: interpolator
        )
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
extension AdaptyViewConfiguration.Animation {
    func getAnimationProperties() -> (Timeline, Interpolator) {
        switch self {
        case .opacity(let timeline, let value): (timeline, value.interpolator)
        case .offset(let timeline, let value): (timeline, value.interpolator)
        case .rotation(let timeline, let value): (timeline, value.interpolator)
        case .scale(let timeline, let value): (timeline, value.interpolator)
        case .width(let timeline, let value): (timeline, value.interpolator)
        case .height(let timeline, let value): (timeline, value.interpolator)
        case .background(let timeline, let value): (timeline, value.interpolator)
        case .border(let timeline, let value): (timeline, value.interpolator)
        case .borderThickness(let timeline, let value): (timeline, value.interpolator)
        case .shadow(let timeline, let value): (timeline, value.interpolator)
        case .shadowOffset(let timeline, let value): (timeline, value.interpolator)
        case .shadowBlurRadius(let timeline, let value): (timeline, value.interpolator)
        }
    }
}

#endif
