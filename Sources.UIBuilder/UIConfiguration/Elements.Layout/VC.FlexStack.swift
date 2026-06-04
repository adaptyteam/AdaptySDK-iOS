//
//  VC.FlexStack.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 04.06.2026.
//

import Foundation


extension VC {
    struct FlexStack: Sendable {
        let condition: [Condition]
        let direction: Flex.Kind
        let horizontalAlignment: HorizontalAlignment
        let verticalAlignment: VerticalAlignment
        let horizontalSpacing: Double
        let verticalSpacing: Double
        let items: [Stack.Item]
        let transition: Transition?
    }
}



