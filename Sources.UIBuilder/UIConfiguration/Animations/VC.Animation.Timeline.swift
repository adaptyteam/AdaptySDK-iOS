//
//  VC.Animation.Timeline.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 16.01.2024
//

import Foundation

extension VC.Animation {
    struct Timeline: Sendable, Hashable {
        let duration: TimeInterval
        let interpolator: Interpolator
        let startDelay: TimeInterval
        let loop: Loop?
        let loopDelay: TimeInterval
        let pingPongDelay: TimeInterval
        let loopCount: Int?
    }
}
