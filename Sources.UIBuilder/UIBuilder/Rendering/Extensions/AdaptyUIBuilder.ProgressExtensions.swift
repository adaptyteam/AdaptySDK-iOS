//
//  AdaptyUIBuilder.ProgressExtensions.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 28.05.2026.
//

protocol AdaptyUIBuilderProgressExtensions {
    var maxValue: Double { get }
    var minValue: Double { get }
}

extension AdaptyUIBuilderProgressExtensions {
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

extension VC.LinearProgress: AdaptyUIBuilderProgressExtensions {}
extension VC.RadialProgress: AdaptyUIBuilderProgressExtensions {}
extension VC.TextProgress: AdaptyUIBuilderProgressExtensions {}

