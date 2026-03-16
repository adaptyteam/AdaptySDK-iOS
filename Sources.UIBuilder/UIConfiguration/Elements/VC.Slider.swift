//
//  VC.Slider.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 14.01.2026.
//

import Foundation

extension VC {
    struct Slider: Sendable, Hashable {
        let value: Variable
        let maxValue: Double
        let minValue: Double
        let stepValue: Double
    }
}
