//
//  Stack.swift
//  AdaptyUI
//
//  Created by Aleksei Valiano on 27.03.2024
//

import Foundation

extension AdaptyUI {
    package struct Stack {
        static let `default` = Stack(
            type: .vertical,
            horizontalAlignment: .center,
            verticalAlignment: .center,
            spacing: 0,
            content: []
        )

        package let type: StackType
        package let horizontalAlignment: HorizontalAlignment
        package let verticalAlignment: VerticalAlignment
        package let spacing: Double
        package let content: [Element]
    }

    package enum StackType: String {
        case vertical = "v_stack"
        case horizontal = "h_stack"
        case z = "z_stack"
    }
}

#if DEBUG
    package extension AdaptyUI.Stack {
        static func create(
            type: AdaptyUI.StackType = `default`.type,
            horizontalAlignment: AdaptyUI.HorizontalAlignment = `default`.horizontalAlignment,
            verticalAlignment: AdaptyUI.VerticalAlignment = `default`.verticalAlignment,
            spacing: Double = `default`.spacing,
            content: [AdaptyUI.Element] = `default`.content
        ) -> Self {
            .init(
                type: type,
                horizontalAlignment: horizontalAlignment,
                verticalAlignment: verticalAlignment,
                spacing: spacing,
                content: content
            )
        }
    }
#endif
