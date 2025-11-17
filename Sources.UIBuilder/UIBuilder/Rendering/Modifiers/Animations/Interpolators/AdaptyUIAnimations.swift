//
//  AdaptyUIAnimations.swift
//
//
//  Created by Aleksey Goncharov on 21.03.2025.
//

#if canImport(UIKit)

import SwiftUI

extension VC.Animation.Interpolator {
    func createAnimation(duration: TimeInterval) -> Animation {
        if #available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, visionOS 1.0, *) {
            switch self {
            case .easeInOut: .easeInOut(duration: duration)
            case .easeIn: .easeIn(duration: duration)
            case .easeOut: .easeOut(duration: duration)
            case .linear: .linear(duration: duration)
            case let .cubicBezier(x1, y1, x2, y2): .timingCurve(x1, y1, x2, y2, duration: duration)
            case .easeInElastic: .adaptyCustomEaseInElastic(duration: duration)
            case .easeOutElastic: .adaptyCustomEaseOutElastic(duration: duration)
            case .easeInOutElastic: .adaptyCustomEaseInOutElastic(duration: duration)
            case .easeInBounce: .adaptyCustomEaseInBounce(duration: duration)
            case .easeOutBounce: .adaptyCustomEaseOutBounce(duration: duration)
            case .easeInOutBounce: .adaptyCustomEaseInOutBounce(duration: duration)
            }
        } else {
            switch self {
            case .easeInOut: .easeInOut(duration: duration)
            case .easeIn: .easeIn(duration: duration)
            case .easeOut: .easeOut(duration: duration)
            case let .cubicBezier(x1, y1, x2, y2): .timingCurve(x1, y1, x2, y2, duration: duration)
            case .linear: .linear(duration: duration)
            default: .easeInOut(duration: duration)
            }
        }
    }
}

#endif
