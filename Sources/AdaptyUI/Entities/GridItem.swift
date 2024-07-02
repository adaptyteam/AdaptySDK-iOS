//
//  GridItem.swift
//  AdaptyUI
//
//  Created by Aleksei Valiano on 23.05.2024
//
//

import Foundation

extension AdaptyUI {
    package struct GridItem: Hashable, Sendable {
        static let defaultHorizontalAlignment: HorizontalAlignment = .center
        static let defaultVerticalAlignment: VerticalAlignment = .center

        package let length: Length
        package let horizontalAlignment: AdaptyUI.HorizontalAlignment
        package let verticalAlignment: AdaptyUI.VerticalAlignment
        package let content: AdaptyUI.Element
    }
}

extension AdaptyUI.GridItem {
    package enum Length: Sendable {
        case fixed(AdaptyUI.Unit)
        case weight(Int)
    }
}

extension AdaptyUI.GridItem.Length: Hashable {
    package func hash(into hasher: inout Hasher) {
        switch self {
        case let .fixed(value):
            hasher.combine(value)
        case let .weight(value):
            hasher.combine(value)
        }
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
