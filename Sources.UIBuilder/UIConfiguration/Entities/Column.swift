//
//  Column.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 23.05.2024
//

import Foundation

extension AdaptyUIConfiguration {
    package struct Column: Sendable, Hashable {
        package let spacing: Double
        package let items: [GridItem]
    }
}

#if DEBUG
package extension AdaptyUIConfiguration.Column {
    static func create(
        spacing: Double = 0,
        items: [AdaptyUIConfiguration.GridItem]
    ) -> Self {
        .init(
            spacing: spacing,
            items: items
        )
    }
}
#endif
