//
//  VC.Slider.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 14.01.2026.
//

import Foundation

package extension VC {
    struct Slider: Sendable, Hashable {
        package let value: Variable
        package let maxValue: Double
        package let minValue: Double
        package let stepValue: Double?
    }
}
