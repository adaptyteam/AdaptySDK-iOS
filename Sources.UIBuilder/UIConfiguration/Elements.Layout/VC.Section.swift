//
//  VC.Section.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 23.05.2024
//

import Foundation

extension VC {
    struct Section: Sendable {
        let index: Variable
        let content: [ElementIndex]
        let transition: Transition?
    }
}


