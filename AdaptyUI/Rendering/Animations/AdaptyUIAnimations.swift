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
    @available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
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

    static func fromInterpolatorFallback(
        _ interpolator: VC.Animation.Interpolator,
        duration: TimeInterval
    ) -> Animation {
        switch interpolator {
        case .easeInOut: .easeInOut(duration: duration)
        case .easeIn: .easeIn(duration: duration)
        case .easeOut: .easeOut(duration: duration)
        case .linear: .linear(duration: duration)
        case let .cubicBezier(x1, y1, x2, y2): .timingCurve(x1, y1, x2, y2)
        default: .linear(duration: duration)
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

    static func create(
        timeline: AdaptyViewConfiguration.Animation.Timeline,
        interpolator: AdaptyViewConfiguration.Animation.Interpolator
    ) -> Animation {
        let result: Animation
        if #available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *) {
            result = .fromInterpolator(
                interpolator,
                duration: timeline.duration
            )
        } else {
            result = .fromInterpolatorFallback(
                interpolator,
                duration: timeline.duration
            )
        }

        return result
            .withTimeline(timeline)
            .delay(timeline.startDelay)
    }
}

#endif
