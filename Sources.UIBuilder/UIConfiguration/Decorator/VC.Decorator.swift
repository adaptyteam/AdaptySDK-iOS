//
//  VC.Decorator.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 27.03.2024
//

import Foundation

package extension VC {
    struct Decorator: Sendable, Hashable {
        package let shapeType: ShapeType
        package let background: Background?
        package let border: Border?
        package let shadow: Shadow?
    }
}

#if DEBUG
package extension VC.Decorator {
    static func create(
        shapeType: VC.ShapeType = .default,
        background: VC.Background? = nil,
        border: VC.Border? = nil,
        shadow: VC.Shadow? = nil
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
