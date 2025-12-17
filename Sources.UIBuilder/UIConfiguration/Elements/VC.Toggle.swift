//
//  VC.Toggle.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 30.05.2024
//

import Foundation

package extension VC {
    struct Toggle: Sendable, Hashable {
        package let onActions: [Action]
        package let offActions: [Action]
        package let onCondition: StateCondition
        package let color: Mode<Color>?
    }
}
