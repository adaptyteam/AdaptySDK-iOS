//
//  Decorator.swift
//  AdaptyUI
//
//  Created by Aleksei Valiano on 27.03.2024
//

import Foundation

extension AdaptyUI {
    public struct Decorator {
        static let defaultType: ShapeType = .rectangle(cornerRadius: CornerRadius.zero)
        public let shapeType: ShapeType
        public let background: Filling?
        public let border: Border?
    }
}
