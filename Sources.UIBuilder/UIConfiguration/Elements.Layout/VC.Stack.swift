//
//  VC.Stack.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 27.03.2024
//

import Foundation

package extension VC {
    struct Stack: Sendable, Hashable {
        package let type: Kind
        package let horizontalAlignment: HorizontalAlignment
        package let verticalAlignment: VerticalAlignment
        package let spacing: Double
        package let items: [Item]
    }
}

package extension VC.Stack {
    var content: [VC.Element] {
        items.map {
            switch $0 {
            case let .space(value):
                .space(value)
            case let .element(element):
                element
            }
        }
    }
}
