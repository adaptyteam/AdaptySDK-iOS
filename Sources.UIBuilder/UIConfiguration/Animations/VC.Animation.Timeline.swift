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
