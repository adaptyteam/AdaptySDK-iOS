//
//  VC.TextProgress.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 16.04.2026.
//

import Foundation

extension VC {
    struct TextProgress: Sendable {
        let format: VC.RangeTextFormat
        let value: Variable
        let transition: Transition
        let actions: [Action]
        let maxValue: Double
        let minValue: Double
        let skipAnimationOnOverflow: Bool
    }
}

extension VC.TextProgress {
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
