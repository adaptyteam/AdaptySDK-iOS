//
//  Decorator.swift
//  AdaptyUI
//
//  Created by Aleksei Valiano on 27.03.2024
//

import Foundation

extension AdaptyUICore {
    package struct Decorator: Sendable, Hashable {
        static let defaultShapeType: ShapeType = .rectangle(cornerRadius: CornerRadius.zero)
        package let shapeType: ShapeType
        package let background: Background?
        package let border: Border?
    }
}

#if DEBUG
    package extension AdaptyUICore.Decorator {
        static func create(
            shapeType: AdaptyUICore.ShapeType = defaultShapeType,
            background: AdaptyUICore.Background? = nil,
            border: AdaptyUICore.Border? = nil
        ) -> Self {
            .init(
                shapeType: shapeType,
                background: background,
                border: border
            )
        }
    }
#endif
