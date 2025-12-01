//
//  VC.Row.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 23.05.2024
//

import Foundation

package extension VC {
    struct Row: Sendable, Hashable {
        package let spacing: Double
        package let items: [GridItem]
    }
}

#if DEBUG
package extension VC.Row {
    static func create(
        spacing: Double = 0,
        items: [VC.GridItem]
    ) -> Self {
        .init(
            spacing: spacing,
            items: items
        )
    }
}
#endif
