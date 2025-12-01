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

extension VC.Stack {
    static let `default` = Self(
        type: .vertical,
        horizontalAlignment: .center,
        verticalAlignment: .center,
        spacing: 0,
        items: []
    )
}

#if DEBUG
package extension VC.Stack {
    static func create(
        type: Kind = `default`.type,
        horizontalAlignment: VC.HorizontalAlignment = `default`.horizontalAlignment,
        verticalAlignment: VC.VerticalAlignment = `default`.verticalAlignment,
        spacing: Double = `default`.spacing,
        content: [VC.Element] = []
    ) -> Self {
        .init(
            type: type,
            horizontalAlignment: horizontalAlignment,
            verticalAlignment: verticalAlignment,
            spacing: spacing,
            items: content.map { .element($0) }
        )
    }
}

package extension VC.Stack {
    static func create(
        type: Kind = `default`.type,
        horizontalAlignment: VC.HorizontalAlignment = `default`.horizontalAlignment,
        verticalAlignment: VC.VerticalAlignment = `default`.verticalAlignment,
        spacing: Double = `default`.spacing,
        items: [Item] = `default`.items
    ) -> Self {
        .init(
            type: type,
            horizontalAlignment: horizontalAlignment,
            verticalAlignment: verticalAlignment,
            spacing: spacing,
            items: items
        )
    }
}
#endif
