//
//  VC.GridItem.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 23.05.2024
//

import Foundation

package extension VC {
    struct GridItem: Sendable, Hashable {
        static let defaultHorizontalAlignment: HorizontalAlignment = .center
        static let defaultVerticalAlignment: VerticalAlignment = .center

        package let length: Length
        package let horizontalAlignment: VC.HorizontalAlignment
        package let verticalAlignment: VC.VerticalAlignment
        package let content: VC.Element
    }
}

package extension VC.GridItem {
    enum Length: Sendable {
        case fixed(VC.Unit)
        case weight(Int)
    }
}

extension VC.GridItem.Length: Hashable {
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
package extension VC.GridItem {
    static func create(
        length: Length,
        horizontalAlignment: VC.HorizontalAlignment = defaultHorizontalAlignment,
        verticalAlignment: VC.VerticalAlignment = defaultVerticalAlignment,
        content: VC.Element
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
