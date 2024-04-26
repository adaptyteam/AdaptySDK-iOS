//
//  Decorator.swift
//  AdaptyUI
//
//  Created by Aleksei Valiano on 27.03.2024
//

import Foundation

extension AdaptyUI {
    package struct Decorator {
        static let defaultShapeType: ShapeType = .rectangle(cornerRadius: CornerRadius.zero)
        package let shapeType: ShapeType
        package let background: Filling?
        package let border: Border?
    }
}
