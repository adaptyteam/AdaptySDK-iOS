//
//  VC.Element.Properties.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 27.03.2024
//

import Foundation

package extension VC.Element {
    struct Properties: Sendable, Hashable {
        package let decorator: VC.Decorator?
        package let padding: VC.EdgeInsets
        package let offset: VC.Offset

        package let opacity: Double
        package let onAppear: [VC.Animation]
    }
}

package extension VC.Element.Properties {
    static let `default` = (
        padding: VC.EdgeInsets.zero,
        offset: VC.Offset.zero,
        opacity: 1.0
    )
}

#if DEBUG
package extension VC.Element.Properties {
    static func create(
        decorator: VC.Decorator? = nil,
        padding: VC.EdgeInsets = `default`.padding,
        offset: VC.Offset = `default`.offset,
        opacity: Double = `default`.opacity,
        onAppear: [VC.Animation] = []
    ) -> Self {
        .init(
            decorator: decorator,
            padding: padding,
            offset: offset,
            opacity: opacity,
            onAppear: onAppear
        )
    }
}
#endif
