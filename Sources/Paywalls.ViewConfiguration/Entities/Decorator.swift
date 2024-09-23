//
//  Decorator.swift
//  AdaptyUI
//
//  Created by Aleksei Valiano on 27.03.2024
//

import Foundation

extension AdaptyUI {
    package struct Decorator: Sendable, Hashable {
        static let defaultShapeType: ShapeType = .rectangle(cornerRadius: CornerRadius.zero)
        package let shapeType: ShapeType
        package let background: Filling?
        package let border: Border?
    }
}

#if DEBUG
    package extension AdaptyUI.Decorator {
        static func create(
            shapeType: AdaptyUI.ShapeType = defaultShapeType,
            background: AdaptyUI.Filling? = nil,
            border: AdaptyUI.Border? = nil
        ) -> Self {
            .init(
                shapeType: shapeType,
                background: background,
                border: border
            )
        }
    }
#endif
