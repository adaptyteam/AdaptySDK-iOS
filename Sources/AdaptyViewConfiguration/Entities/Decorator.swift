//
//  Decorator.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 27.03.2024
//

import Foundation

extension AdaptyViewConfiguration {
    package struct Decorator: Sendable, Hashable {
        static let defaultShapeType: ShapeType = .rectangle(cornerRadius: CornerRadius.zero)
        package let shapeType: ShapeType
        package let background: Background?
        package let border: Border?
    }
}

#if DEBUG
package extension AdaptyViewConfiguration.Decorator {
    static func create(
        shapeType: AdaptyViewConfiguration.ShapeType = defaultShapeType,
        background: AdaptyViewConfiguration.Background? = nil,
        border: AdaptyViewConfiguration.Border? = nil
    ) -> Self {
        .init(
            shapeType: shapeType,
            background: background,
            border: border
        )
    }
}
#endif
