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
    }
}
