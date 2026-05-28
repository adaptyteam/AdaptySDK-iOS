//
//  VC.RadialProgress.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 16.04.2026.
//

import Foundation

extension VC {
    struct RadialProgress: Sendable {
        let thickness: Double?
        let sweepAngle: Double
        let startAngle: Double
        let clockwise: Bool
        let roundedCaps: Bool
        let asset: AssetReference
        let clip: Bool
        let value: Variable
        let transition: Transition
        let actions: [Action]
        let maxValue: Double
        let minValue: Double
        let skipAnimationOnOverflow: Bool
    }
}

extension VC.RadialProgress {
    func normalize(_ raw: Double) -> Double {
        let span = maxValue - minValue
        guard span > 0 else { return 0 }
        let clamped = min(max(raw, minValue), maxValue)
        return (clamped - minValue) / span
    }

    func isOverflow(_ raw: Double) -> Bool {
        raw < minValue || raw > maxValue
    }
}
