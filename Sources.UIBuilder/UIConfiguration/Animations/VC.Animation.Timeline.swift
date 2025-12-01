//
//  VC.Animation.Timeline.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 16.01.2024
//

import Foundation

package extension VC.Animation {
    struct Timeline: Sendable, Hashable {
        package let duration: TimeInterval
        package let interpolator: Interpolator
        package let startDelay: TimeInterval
        package let loop: Loop?
        package let loopDelay: TimeInterval
        package let pingPongDelay: TimeInterval
        package let loopCount: Int?
    }
}

extension VC.Animation.Timeline {
    static let `default` = Self(
        duration: 0.3,
        interpolator: .default,
        startDelay: 0.0,
        loop: nil,
        loopDelay: 0.0,
        pingPongDelay: 0.0,
        loopCount: nil
    )
}

#if DEBUG
package extension VC.Animation.Timeline {
    static func create(
        startDelay: TimeInterval = Self.default.startDelay,
        duration: TimeInterval = Self.default.duration,
        interpolator: VC.Animation.Interpolator = Self.default.interpolator,
        loop: Loop? = Self.default.loop,
        loopDelay: TimeInterval = Self.default.loopDelay,
        pingPongDelay: TimeInterval = Self.default.pingPongDelay,
        loopCount: Int? = Self.default.loopCount
    ) -> Self {
        .init(
            duration: duration,
            interpolator: interpolator,
            startDelay: startDelay,
            loop: loop,
            loopDelay: loopDelay,
            pingPongDelay: pingPongDelay,
            loopCount: loopCount
        )
    }
}
#endif
