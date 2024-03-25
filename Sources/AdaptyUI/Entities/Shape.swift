//
//  Shape.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 30.06.2023
//

import Foundation

extension AdaptyUI {
    public struct Shape {
        static let defaultType: ShapeType = .rectangle(cornerRadius: CornerRadius.zero)

        public let background: Filling?
        public let border: Border?
        public let type: ShapeType

        public struct Border {
            static let defaultThickness = 1.0

            public let filling: AdaptyUI.Filling
            public let thickness: Double
        }
    }
}
