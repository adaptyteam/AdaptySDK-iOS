//
//  VC.LinearProgress.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 16.04.2026.
//

import Foundation

extension VC {
    struct LinearProgress: Sendable {
        let orientation: Orientation
        let cornerRadius: CornerRadius
        let asset: AssetReference
        let imageAspect: AspectRatio
        let clip: Bool
        let value: Variable
        let transition: Transition
        let actions: [Action]
        let maxValue: Double
        let minValue: Double
        let skipAnimationOnOverflow: Bool
    }
}

extension VC.LinearProgress {
    enum Orientation: Sendable {
        case horizontal(VC.HorizontalAlignment)
        case vertical(VC.VerticalAlignment)
    }

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
