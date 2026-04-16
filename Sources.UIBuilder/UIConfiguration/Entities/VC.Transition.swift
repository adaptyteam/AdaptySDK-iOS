//
//  VC.Transition.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 16.01.2024
//

import Foundation

extension VC {
    struct Transition: Sendable, Hashable {
        let startDelay: TimeInterval
        let duration: TimeInterval
        let interpolator: VC.Animation.Interpolator
    }
}
