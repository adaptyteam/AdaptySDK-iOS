//
//  VC.WheelRangePicker.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 15.03.2026.
//

import Foundation

extension VC {
    struct WheelRangePicker: Sendable {
        let value: Variable
        let maxValue: Double
        let minValue: Double
        let stepValue: Double
        let format: VC.RangeTextFormat
    }
}
