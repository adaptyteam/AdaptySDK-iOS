//
//  Decorator.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 27.03.2024
//

import Foundation

package extension AdaptyUIConfiguration {
    struct Decorator: Sendable, Hashable {
        static let defaultShapeType: ShapeType = .rectangle(cornerRadius: CornerRadius.zero)
        package let shapeType: ShapeType
        package let background: Background?
        package let border: Border?
        package let shadow: Shadow?
    }
}

#if DEBUG
package extension AdaptyUIConfiguration.Decorator {
    static func create(
        shapeType: AdaptyUIConfiguration.ShapeType = defaultShapeType,
        background: AdaptyUIConfiguration.Background? = nil,
        border: AdaptyUIConfiguration.Border? = nil,
        shadow: AdaptyUIConfiguration.Shadow? = nil
    ) -> Self {
        .init(
            shapeType: shapeType,
            background: background,
            border: border,
            shadow: shadow
        )
    }
}
#endif
