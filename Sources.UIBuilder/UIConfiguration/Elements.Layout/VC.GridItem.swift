//
//  VC.GridItem.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 23.05.2024
//

import Foundation

package extension VC {
    struct GridItem: Sendable, Hashable {
        package let length: Length
        package let horizontalAlignment: VC.HorizontalAlignment
        package let verticalAlignment: VC.VerticalAlignment
        package let content: VC.Element
    }
}

extension VC.GridItem {
    static let `default` = (
        horizontalAlignment: VC.HorizontalAlignment.center,
        verticalAlignment: VC.VerticalAlignment.center
    )
}

#if DEBUG
package extension VC.GridItem {
    static func create(
        length: Length,
        horizontalAlignment: VC.HorizontalAlignment = `default`.horizontalAlignment,
        verticalAlignment: VC.VerticalAlignment = `default`.verticalAlignment,
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
