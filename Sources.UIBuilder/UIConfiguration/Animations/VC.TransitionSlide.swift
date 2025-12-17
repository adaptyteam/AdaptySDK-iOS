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
