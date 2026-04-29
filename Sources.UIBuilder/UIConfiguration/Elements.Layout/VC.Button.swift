//
//  VC.Button.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 27.03.2024
//

import Foundation

extension VC {
    struct Button: Sendable, Hashable {
        let actions: [Action]
        let content: ElementIndex
        let legacySelectedContent: ElementIndex?
        let legacyIsSelected: Variable?
    }
}
