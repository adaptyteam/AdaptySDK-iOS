//
//  Stack.swift
//  AdaptyUI
//
//  Created by Aleksei Valiano on 28.03.2024
//
//

import Foundation

extension AdaptyUI.ViewConfiguration {
    struct Stack {
        let type: AdaptyUI.StackType
        let horizontalAlignment: AdaptyUI.HorizontalAlignment
        let verticalAlignment: AdaptyUI.VerticalAlignment
        let elements: [AdaptyUI.ViewConfiguration.Element]
    }
}

extension AdaptyUI.ViewConfiguration.Localizer {
    func stack(_ from: AdaptyUI.ViewConfiguration.Stack) -> AdaptyUI.Stack {
        .init(
            type: from.type,
            horizontalAlignment: from.horizontalAlignment,
            verticalAlignment: from.verticalAlignment,
            elements: from.elements.map(element)
        )
    }
}
