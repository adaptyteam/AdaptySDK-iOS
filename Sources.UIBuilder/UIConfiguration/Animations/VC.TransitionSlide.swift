//
//  VC.TransitionSlide.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 16.01.2024
//

import Foundation

extension VC {
    struct TransitionSlide: Sendable, Hashable {
        let startDelay: TimeInterval
        let duration: TimeInterval
        let interpolator: VC.Animation.Interpolator
    }
}
