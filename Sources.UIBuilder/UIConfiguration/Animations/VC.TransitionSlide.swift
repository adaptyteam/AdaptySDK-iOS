//
//  VC.TransitionSlide.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 16.01.2024
//

import Foundation

package extension VC {
    struct TransitionSlide: Sendable, Hashable {
        package let startDelay: TimeInterval
        package let duration: TimeInterval
        package let interpolator: VC.Animation.Interpolator
    }
}

extension VC.TransitionSlide {
    static let `default` = Self(
        startDelay: 0.0,
        duration: 0.3,
        interpolator: VC.Animation.Interpolator.default
    )
}

#if DEBUG
package extension VC.TransitionSlide {
    static func create(
        startDelay: TimeInterval = `default`.startDelay,
        duration: TimeInterval = `default`.duration,
        interpolator: VC.Animation.Interpolator = `default`.interpolator
    ) -> Self {
        .init(
            startDelay: startDelay,
            duration: duration,
            interpolator: interpolator
        )
    }
}
#endif
