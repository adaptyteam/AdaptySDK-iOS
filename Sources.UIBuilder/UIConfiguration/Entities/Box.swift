//
//  Box.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 25.03.2024
//

import Foundation

package extension AdaptyUIConfiguration {
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

package extension AdaptyUIConfiguration.Box {
    enum Length: Sendable {
        case fixed(AdaptyUIConfiguration.Unit)
        case flexible(min: AdaptyUIConfiguration.Unit?, max: AdaptyUIConfiguration.Unit?)
        case shrinkable(min: AdaptyUIConfiguration.Unit, max: AdaptyUIConfiguration.Unit?)
        case fillMax
    }
}

extension AdaptyUIConfiguration.Box.Length: Hashable {
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
package extension AdaptyUIConfiguration.Box {
    static func create(
        width: Length? = nil,
        height: Length? = nil,
        horizontalAlignment: AdaptyUIConfiguration.HorizontalAlignment = defaultHorizontalAlignment,
        verticalAlignment: AdaptyUIConfiguration.VerticalAlignment = defaultVerticalAlignment,
        content: AdaptyUIConfiguration.Element? = nil
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
