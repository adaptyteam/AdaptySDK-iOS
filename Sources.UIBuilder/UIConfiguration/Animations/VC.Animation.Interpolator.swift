//
//  VC.Animation.Interpolator.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 16.01.2024
//

import Foundation

extension VC.Animation {
    enum Interpolator: Sendable, Equatable {
        case easeInOut
        case easeIn
        case easeOut
        case linear
        case easeInElastic
        case easeOutElastic
        case easeInOutElastic
        case easeInBounce
        case easeOutBounce
        case easeInOutBounce
        case cubicBezier(Double, Double, Double, Double)
    }
}
