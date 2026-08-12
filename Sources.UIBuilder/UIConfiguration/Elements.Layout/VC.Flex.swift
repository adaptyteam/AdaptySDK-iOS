//
//  VC.Flex.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 04.06.2026.
//

import Foundation

extension VC {
    struct Flex: Sendable {
        let condition: [Condition]
        let direction: Flex.Direction
        let width: AutoSizeMode
        let height: AutoSizeMode
        let horizontalSpacing: Double
        let verticalSpacing: Double
        let items: [GridItem]
        let transition: Transition?
    }
}

