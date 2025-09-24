//
//  VC.Box.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 25.03.2024
//

import Foundation

package extension VC {
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

package extension VC.Box {
    enum Length: Sendable {
        case fixed(VC.Unit)
        case flexible(min: VC.Unit?, max: VC.Unit?)
        case shrinkable(min: VC.Unit, max: VC.Unit?)
        case fillMax
    }
}

extension VC.Box.Length: Hashable {
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
package extension VC.Box {
    static func create(
        width: Length? = nil,
        height: Length? = nil,
        horizontalAlignment: VC.HorizontalAlignment = defaultHorizontalAlignment,
        verticalAlignment: VC.VerticalAlignment = defaultVerticalAlignment,
        content: VC.Element? = nil
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
