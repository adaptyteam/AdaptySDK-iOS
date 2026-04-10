//
//  VC.Section.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 23.05.2024
//

import Foundation

extension VC {
    struct Section: Sendable, Hashable {
        let index: Variable
        let content: [Element]
        let animationDuration: TimeInterval?
        let animationInterpolator: Animation.Interpolator
    }
}
