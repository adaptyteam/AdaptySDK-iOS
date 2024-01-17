//
//  Transition.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 16.01.2024
//

import Foundation

extension AdaptyUI {
    public enum Transition {
        case fade(TransitionFade)
        case unknown(String)
    }
}

extension AdaptyUI.Transition {
    public enum Interpolator {
        static let `default`: AdaptyUI.Transition.Interpolator = .easeInOut

        case easeInOut
        case easeIn
        case easeOut
        case linear
    }
}

extension AdaptyUI {
    public struct TransitionFade {
        static let defaultStartDelay: TimeInterval = 0.0
        static let defaultDuration: TimeInterval = 0.3
        static let defaultInterpolator = AdaptyUI.Transition.Interpolator.default

        public let startDelay: TimeInterval
        public let duration: TimeInterval
        public let interpolator: AdaptyUI.Transition.Interpolator
    }
}
