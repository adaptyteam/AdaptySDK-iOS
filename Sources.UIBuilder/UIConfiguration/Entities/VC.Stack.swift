//
//  VC.Stack.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 27.03.2024
//

import Foundation

package extension VC {
    struct Stack: Sendable, Hashable {
        static let `default` = Stack(
            type: .vertical,
            horizontalAlignment: .center,
            verticalAlignment: .center,
            spacing: 0,
            items: []
        )

        package let type: StackType
        package let horizontalAlignment: HorizontalAlignment
        package let verticalAlignment: VerticalAlignment
        package let spacing: Double
        package let items: [StackItem]

        package var content: [Element] {
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

    enum StackItem: Sendable {
        case space(Int)
        case element(Element)
    }

    enum StackType: String {
        case vertical = "v_stack"
        case horizontal = "h_stack"
        case z = "z_stack"
    }
}

extension VC.StackItem: Hashable {
    package func hash(into hasher: inout Hasher) {
        switch self {
        case let .space(value):
            hasher.combine(1)
            hasher.combine(value)
        case let .element(value):
            hasher.combine(2)
            hasher.combine(value)
        }
    }
}

#if DEBUG
package extension VC.Stack {
    static func create(
        type: VC.StackType = `default`.type,
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
        type: VC.StackType = `default`.type,
        horizontalAlignment: VC.HorizontalAlignment = `default`.horizontalAlignment,
        verticalAlignment: VC.VerticalAlignment = `default`.verticalAlignment,
        spacing: Double = `default`.spacing,
        items: [VC.StackItem] = `default`.items
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
