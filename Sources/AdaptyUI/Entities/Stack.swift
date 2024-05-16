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
