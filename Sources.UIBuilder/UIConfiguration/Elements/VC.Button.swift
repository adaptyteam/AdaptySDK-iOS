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
        let content: Element
        let legacySelectedContent: Element?
        let legacyIsSelected: Variable?
    }
}
