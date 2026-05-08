//
//  VC.Animation.Interpolator.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 16.01.2024
//

import Foundation

extension VC.Animation {
    enum Interpolator: Sendable {
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

        // SwiftUI's `.repeatForever` / `.repeatCount` don't compose with
        // `Animation(CustomAnimation)` — the custom curve is dropped and the
        // animation degrades to default easing. These cases must use the
        // manual loop path instead of `animateWithNativeRepeat`.
        var usesCustomCurve: Bool {
            switch self {
            case .easeInElastic, .easeOutElastic, .easeInOutElastic,
                 .easeInBounce, .easeOutBounce, .easeInOutBounce:
                true
            default:
                false
            }
        }
    }
}
