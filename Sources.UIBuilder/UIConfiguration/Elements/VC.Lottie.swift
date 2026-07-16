//
//  VC.Lottie.swift
//  AdaptyUIBuilder
//
//  Proof of concept: model for the Lottie animation element.
//

import Foundation

extension VC {
    struct Lottie: Sendable {
        let animationId: String
        /// Text overrides keyed by animation keypath (usually the AE layer name), e.g. ["Text 1": "Hello"].
        let texts: [String: String]
        /// Color overrides: animation keypath -> "#RRGGBB"/"#RRGGBBAA", e.g. ["Text 1.Color": "#E11D48FF"].
        let colors: [String: String]
        let loop: AdaptyUILottieLoop
        let speed: Double
        let autoplay: Bool
        let fit: AdaptyUILottieFit
    }
}
