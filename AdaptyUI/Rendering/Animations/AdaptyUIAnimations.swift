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
extension Animation {
    @available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, visionOS 1.0, *)
    static func fromInterpolator(
        _ interpolator: VC.Animation.Interpolator,
        duration: TimeInterval
    ) -> Animation {
        switch interpolator {
        case .easeInOut: .easeInOut(duration: duration)
        case .easeIn: .easeIn(duration: duration)
        case .easeOut: .easeOut(duration: duration)
        case .linear: .linear(duration: duration)
        case let .cubicBezier(x1, y1, x2, y2): .timingCurve(x1, y1, x2, y2, duration: duration)
        case .easeInElastic: .adaptyCustomEaseInElastic(duration: duration)
        case .easeOutElastic: .adaptyCustomEaseOutElastic(duration: duration)
        case .easeInOutElastic: .adaptyCustomEaseInOutElastic(duration: duration)
        case .easeInBounce: .adaptyCustomEaseInBounce(duration: duration)
        case .easeOutBounce: .adaptyCustomEaseOutBounce(duration: duration)
        case .easeInOutBounce: .adaptyCustomEaseInOutBounce(duration: duration)
        }
    }

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
    static func create(
        timeline: AdaptyViewConfiguration.Animation.Timeline,
        interpolator: AdaptyViewConfiguration.Animation.Interpolator
    ) -> Animation {
        .fromInterpolator(
            interpolator,
            duration: timeline.duration
        )
        .withTimeline(timeline)
        .delay(timeline.startDelay)
    }

    static func createFallback(
        timeline: AdaptyViewConfiguration.Animation.Timeline,
        interpolator: VC.Animation.Interpolator
    ) -> (Animation, (Double) -> Double) {
        let animation: Animation = switch interpolator {
        case .easeInOut: .easeInOut(duration: timeline.duration)
        case .easeIn: .easeIn(duration: timeline.duration)
        case .easeOut: .easeOut(duration: timeline.duration)
        case let .cubicBezier(x1, y1, x2, y2): .timingCurve(x1, y1, x2, y2, duration: timeline.duration)
        default: .linear(duration: timeline.duration)
            //        case .easeInElastic: .adaptyCustomEaseInElastic(duration: duration)
            //        case .easeOutElastic: .adaptyCustomEaseOutElastic(duration: duration)
            //        case .easeInOutElastic: .adaptyCustomEaseInOutElastic(duration: duration)
            //        case .easeInBounce: .adaptyCustomEaseInBounce(duration: duration)
            //        case .easeOutBounce: .adaptyCustomEaseOutBounce(duration: duration)
            //        case .easeInOutBounce: .adaptyCustomEaseInOutBounce(duration: duration)
        }

        let functor: (Double) -> Double = switch interpolator {
        case .easeInElastic: AdaptyUICustomAnimationFunctions.easeInElastic(_:)
        case .easeOutElastic: AdaptyUICustomAnimationFunctions.easeOutElastic(_:)
        case .easeInOutElastic: AdaptyUICustomAnimationFunctions.easeInOutElastic(_:)
        case .easeInBounce: AdaptyUICustomAnimationFunctions.easeInBounce(_:)
        case .easeOutBounce: AdaptyUICustomAnimationFunctions.easeOutBounce(_:)
        case .easeInOutBounce: AdaptyUICustomAnimationFunctions.easeInOutBounce(_:)
        default: { $0 }
        }

        return (
            animation
                .withTimeline(timeline)
                .delay(timeline.startDelay),
            functor
        )
    }
}

#endif
