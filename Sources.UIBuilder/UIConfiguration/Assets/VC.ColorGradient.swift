//
//  VC.ColorGradient.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 29.06.2023
//

import Foundation

package extension VC {
    struct ColorGradient: CustomAsset, Sendable, Hashable {
        package let customId: String?
        package let kind: Kind
        package let start: Point
        package let end: Point
        package let items: [Item]
    }
}

#if DEBUG
package extension VC.ColorGradient {
    static func create(
        customId: String? = nil,
        kind: Kind,
        start: VC.Point,
        end: VC.Point,
        items: [Item]
    ) -> Self {
        .init(
            customId: customId,
            kind: kind,
            start: start,
            end: end,
            items: items
        )
    }
}
#endif
