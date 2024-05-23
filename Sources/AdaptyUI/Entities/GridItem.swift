//
//  GridItem.swift
//  AdaptyUI
//
//  Created by Aleksei Valiano on 23.05.2024
//
//

import Foundation

extension AdaptyUI {
    package struct GridItem {
        static let defaultHorizontalAlignment: HorizontalAlignment = .center
        static let defaultVerticalAlignment: VerticalAlignment = .center

        package let length: Length
        package let horizontalAlignment: AdaptyUI.HorizontalAlignment
        package let verticalAlignment: AdaptyUI.VerticalAlignment
        package let content: AdaptyUI.Element
    }
}

#if DEBUG
    package extension AdaptyUI.GridItem {
        static func create(
            length: Length,
            horizontalAlignment: AdaptyUI.HorizontalAlignment = defaultHorizontalAlignment,
            verticalAlignment: AdaptyUI.VerticalAlignment = defaultVerticalAlignment,
            content: AdaptyUI.Element
        ) -> Self {
            .init(
                length: length,
                horizontalAlignment: horizontalAlignment,
                verticalAlignment: verticalAlignment,
                content: content
            )
        }
    }
#endif

extension AdaptyUI.GridItem {
    package enum Length {
        case fixed(AdaptyUI.Unit)
        case weight(Int)
    }
}
