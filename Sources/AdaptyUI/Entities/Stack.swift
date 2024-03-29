//
//  Stack.swift
//  AdaptyUI
//
//  Created by Aleksei Valiano on 27.03.2024
//

import Foundation

extension AdaptyUI {
    public struct Stack {
        static let `default` = Stack(
            type: .vertical,
            horizontalAlignment: .center,
            verticalAlignment: .center,
            elements: []
        )

        public let type: StackType
        public let horizontalAlignment: HorizontalAlignment
        public let verticalAlignment: VerticalAlignment
        public let elements: [Element]
    }

    public enum StackType: String {
        case vertical = "v_stack"
        case horizontal = "h_stack"
        case z = "z_stack"
    }
}
