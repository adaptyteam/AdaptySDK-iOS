//
//  AdaptyUIBuilder.ProgressExtensions.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 28.05.2026.
//

extension AdaptyUIBuilder {
    protocol ProgressExtensions {
        var maxValue: Double { get }
        var minValue: Double { get }
    }
}

extension AdaptyUIBuilder.ProgressExtensions {
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

extension VC.LinearProgress: AdaptyUIBuilder.ProgressExtensions {}
extension VC.RadialProgress: AdaptyUIBuilder.ProgressExtensions {}
extension VC.TextProgress: AdaptyUIBuilder.ProgressExtensions {}

