//
//  GridItem.swift
//  AdaptyUI
//
//  Created by Aleksei Valiano on 23.05.2024
//
//

import Foundation

extension AdaptyUICore {
    package struct GridItem: Sendable, Hashable {
        static let defaultHorizontalAlignment: HorizontalAlignment = .center
        static let defaultVerticalAlignment: VerticalAlignment = .center

        package let length: Length
        package let horizontalAlignment: AdaptyUICore.HorizontalAlignment
        package let verticalAlignment: AdaptyUICore.VerticalAlignment
        package let content: AdaptyUICore.Element
    }
}

extension AdaptyUICore.GridItem {
    package enum Length: Sendable {
        case fixed(AdaptyUICore.Unit)
        case weight(Int)
    }
}

extension AdaptyUICore.GridItem.Length: Hashable {
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
    package extension AdaptyUICore.GridItem {
        static func create(
            length: Length,
            horizontalAlignment: AdaptyUICore.HorizontalAlignment = defaultHorizontalAlignment,
            verticalAlignment: AdaptyUICore.VerticalAlignment = defaultVerticalAlignment,
            content: AdaptyUICore.Element
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
