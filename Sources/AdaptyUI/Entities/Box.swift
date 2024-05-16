//
//  Box.swift
//  AdaptyUI
//
//  Created by Aleksei Valiano on 25.03.2024
//

import Foundation

extension AdaptyUI {
    package struct Box {
        package let width: Length?
        package let height: Length?
        package let horizontalAlignment: HorizontalAlignment
        package let verticalAlignment: VerticalAlignment
        package let content: Element
    }
}

extension AdaptyUI.Box {
    package enum Length {
        case fixed(AdaptyUI.Unit)
        case min(AdaptyUI.Unit)
        case fillMax
    }
}
