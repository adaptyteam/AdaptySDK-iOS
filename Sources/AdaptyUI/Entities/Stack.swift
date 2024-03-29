//
//  Stack.swift
//  AdaptyUI
//
//  Created by Aleksei Valiano on 27.03.2024
//

import Foundation

extension AdaptyUI {
    public struct Stack {
        public let type: StackType
        public let horizontalAlignment: HorizontalAlignment
        public let verticalAlignment: VerticalAlignment
        public let elements: [Element]
    }

    public enum StackType: String {
        case vertical
        case horizontal
        case z
    }
}
