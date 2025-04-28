//
//  GridItem.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 23.05.2024
//

import Foundation

extension AdaptyViewConfiguration {
    package struct GridItem: Sendable, Hashable {
        static let defaultHorizontalAlignment: HorizontalAlignment = .center
        static let defaultVerticalAlignment: VerticalAlignment = .center

        package let length: Length
        package let horizontalAlignment: AdaptyViewConfiguration.HorizontalAlignment
        package let verticalAlignment: AdaptyViewConfiguration.VerticalAlignment
        package let content: AdaptyViewConfiguration.Element
    }
}

extension AdaptyViewConfiguration.GridItem {
    package enum Length: Sendable {
        case fixed(AdaptyViewConfiguration.Unit)
        case weight(Int)
    }
}

extension AdaptyViewConfiguration.GridItem.Length: Hashable {
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
    package extension AdaptyViewConfiguration.GridItem {
        static func create(
            length: Length,
            horizontalAlignment: AdaptyViewConfiguration.HorizontalAlignment = defaultHorizontalAlignment,
            verticalAlignment: AdaptyViewConfiguration.VerticalAlignment = defaultVerticalAlignment,
            content: AdaptyViewConfiguration.Element
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
