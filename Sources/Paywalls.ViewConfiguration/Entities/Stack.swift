//
//  Stack.swift
//  AdaptyUI
//
//  Created by Aleksei Valiano on 27.03.2024
//

import Foundation

extension AdaptyUICore {
    package struct Stack: Sendable, Hashable {
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

    package enum StackItem: Sendable {
        case space(Int)
        case element(Element)
    }

    package enum StackType: String {
        case vertical = "v_stack"
        case horizontal = "h_stack"
        case z = "z_stack"
    }
}

extension AdaptyUICore.StackItem: Hashable {
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
    package extension AdaptyUICore.Stack {
        static func create(
            type: AdaptyUICore.StackType = `default`.type,
            horizontalAlignment: AdaptyUICore.HorizontalAlignment = `default`.horizontalAlignment,
            verticalAlignment: AdaptyUICore.VerticalAlignment = `default`.verticalAlignment,
            spacing: Double = `default`.spacing,
            content: [AdaptyUICore.Element] = []
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

    package extension AdaptyUICore.Stack {
        static func create(
            type: AdaptyUICore.StackType = `default`.type,
            horizontalAlignment: AdaptyUICore.HorizontalAlignment = `default`.horizontalAlignment,
            verticalAlignment: AdaptyUICore.VerticalAlignment = `default`.verticalAlignment,
            spacing: Double = `default`.spacing,
            items: [AdaptyUICore.StackItem] = `default`.items
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
