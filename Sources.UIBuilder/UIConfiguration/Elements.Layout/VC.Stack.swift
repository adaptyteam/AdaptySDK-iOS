//
//  VC.Stack.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 27.03.2024
//

import Foundation

extension VC {
    struct Stack: Sendable, Hashable {
        let type: Kind
        let horizontalAlignment: HorizontalAlignment
        let verticalAlignment: VerticalAlignment
        let spacing: Double
        let items: [Item]
    }
}

extension VC.Stack {
    @inlinable
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
