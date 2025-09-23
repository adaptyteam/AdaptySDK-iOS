//
//  GridItem.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 23.05.2024
//

import Foundation

extension AdaptyUIConfiguration {
    package struct GridItem: Sendable, Hashable {
        static let defaultHorizontalAlignment: HorizontalAlignment = .center
        static let defaultVerticalAlignment: VerticalAlignment = .center

        package let length: Length
        package let horizontalAlignment: AdaptyUIConfiguration.HorizontalAlignment
        package let verticalAlignment: AdaptyUIConfiguration.VerticalAlignment
        package let content: AdaptyUIConfiguration.Element
    }
}

extension AdaptyUIConfiguration.GridItem {
    package enum Length: Sendable {
        case fixed(AdaptyUIConfiguration.Unit)
        case weight(Int)
    }
}

extension AdaptyUIConfiguration.GridItem.Length: Hashable {
    package func hash(into hasher: inout Hasher) {
        switch self {
        case let .fixed(value):
            hasher.combine(1)
            hasher.combine(value)
        case let .weight(value):
            hasher.combine(2)
            hasher.combine(value)
        }
    }
}

#if DEBUG
package extension AdaptyUIConfiguration.GridItem {
    static func create(
        length: Length,
        horizontalAlignment: AdaptyUIConfiguration.HorizontalAlignment = defaultHorizontalAlignment,
        verticalAlignment: AdaptyUIConfiguration.VerticalAlignment = defaultVerticalAlignment,
        content: AdaptyUIConfiguration.Element
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
