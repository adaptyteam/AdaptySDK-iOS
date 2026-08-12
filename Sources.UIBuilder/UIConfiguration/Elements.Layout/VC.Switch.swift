//
//  VC.Switch.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 04.06.2026.
//

import Foundation

extension VC {
    struct Switch: Sendable {
        let `cases`: [Case]
        let `default`: ElementIndex
        let transition: Transition?
    }

    struct Case: Sendable {
        let condition: [Condition]
        let content: ElementIndex
    }
}
