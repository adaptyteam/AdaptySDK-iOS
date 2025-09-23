//
//  File.swift
//  Adapty
//
//  Created by Alexey Goncharov on 3/21/25.
//

#if canImport(UIKit)

import SwiftUI

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
struct AdaptyUICustomAnimation: CustomAnimation {
    private let id: String
    private let duration: TimeInterval
    private let functor: @Sendable (Double) -> Double

    init(
        id: String,
        duration: TimeInterval,
        functor: @escaping @Sendable (Double) -> Double
    ) {
        self.id = id
        self.duration = duration
        self.functor = functor
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(duration)
    }

    func animate<V>(value: V, time: TimeInterval, context: inout AnimationContext<V>) -> V? where V: VectorArithmetic {
        if time > duration { return nil }

        let p = time / duration
        let y = functor(p)
        return value.scaled(by: y)
    }
}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension AdaptyUICustomAnimation: Equatable {
    static func == (lhs: AdaptyUICustomAnimation, rhs: AdaptyUICustomAnimation) -> Bool {
        lhs.duration == rhs.duration
    }
}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension Animation {
    static func adaptyCustomEaseInElastic(duration: TimeInterval) -> Animation {
        Animation(
            AdaptyUICustomAnimation(
                id: "adaptyui_custom_ease_in_elastic",
                duration: duration,
                functor: AdaptyUICustomAnimationFunctions.easeInElastic
            )
        )
    }

    static func adaptyCustomEaseOutElastic(duration: TimeInterval) -> Animation {
        Animation(
            AdaptyUICustomAnimation(
                id: "adaptyui_custom_ease_out_elastic",
                duration: duration,
                functor: AdaptyUICustomAnimationFunctions.easeOutElastic
            )
        )
    }

    static func adaptyCustomEaseInOutElastic(duration: TimeInterval) -> Animation {
        Animation(
            AdaptyUICustomAnimation(
                id: "adaptyui_custom_ease_in_out_elastic",
                duration: duration,
                functor: AdaptyUICustomAnimationFunctions.easeInOutElastic
            )
        )
    }

    static func adaptyCustomEaseInBounce(duration: TimeInterval) -> Animation {
        Animation(
            AdaptyUICustomAnimation(
                id: "adaptyui_custom_ease_in_bounce",
                duration: duration,
                functor: AdaptyUICustomAnimationFunctions.easeInBounce
            )
        )
    }

    static func adaptyCustomEaseOutBounce(duration: TimeInterval) -> Animation {
        Animation(
            AdaptyUICustomAnimation(
                id: "adaptyui_custom_ease_out_bounce",
                duration: duration,
                functor: AdaptyUICustomAnimationFunctions.easeOutBounce
            )
        )
    }

    static func adaptyCustomEaseInOutBounce(duration: TimeInterval) -> Animation {
        Animation(
            AdaptyUICustomAnimation(
                id: "adaptyui_custom_ease_in_out_bounce",
                duration: duration,
                functor: AdaptyUICustomAnimationFunctions.easeInOutBounce
            )
        )
    }
}

#endif
