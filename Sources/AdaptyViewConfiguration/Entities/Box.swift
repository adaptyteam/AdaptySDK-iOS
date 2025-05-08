//
//  Box.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 25.03.2024
//

import Foundation

package extension AdaptyViewConfiguration {
    struct Box: Sendable, Hashable {
        static let defaultHorizontalAlignment: HorizontalAlignment = .center
        static let defaultVerticalAlignment: VerticalAlignment = .center

        package let width: Length?
        package let height: Length?
        package let horizontalAlignment: HorizontalAlignment
        package let verticalAlignment: VerticalAlignment
        package let content: Element?
    }
}

package extension AdaptyViewConfiguration.Box {
    enum Length: Sendable {
        case fixed(AdaptyViewConfiguration.Unit)
        case flexible(min: AdaptyViewConfiguration.Unit?, max: AdaptyViewConfiguration.Unit?)
        case shrinkable(min: AdaptyViewConfiguration.Unit, max: AdaptyViewConfiguration.Unit?)
        case fillMax
    }
}

extension AdaptyViewConfiguration.Box.Length: Hashable {
    package func hash(into hasher: inout Hasher) {
        switch self {
        case let .fixed(value):
            hasher.combine(1)
            hasher.combine(value)
        case let .flexible(min, max):
            hasher.combine(2)
            hasher.combine(min)
            hasher.combine(max)
        case let .shrinkable(min, max):
            hasher.combine(3)
            hasher.combine(min)
            hasher.combine(max)
        case .fillMax:
            hasher.combine(4)
        }
    }
}

#if DEBUG
    package extension AdaptyViewConfiguration.Box {
        static func create(
            width: Length? = nil,
            height: Length? = nil,
            horizontalAlignment: AdaptyViewConfiguration.HorizontalAlignment = defaultHorizontalAlignment,
            verticalAlignment: AdaptyViewConfiguration.VerticalAlignment = defaultVerticalAlignment,
            content: AdaptyViewConfiguration.Element? = nil
        ) -> Self {
            .init(
                width: width,
                height: height,
                horizontalAlignment: horizontalAlignment,
                verticalAlignment: verticalAlignment,
                content: content
            )
        }
    }
#endif
