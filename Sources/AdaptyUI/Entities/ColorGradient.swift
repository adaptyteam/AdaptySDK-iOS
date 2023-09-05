//
//  ColorGradient.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 29.06.2023
//

import Foundation

extension AdaptyUI {
    public struct ColorGradient {
        public let kind: Kind
        public let start: Point
        public let end: Point
        public let items: [Item]
    }
}

extension AdaptyUI.ColorGradient {
    public struct Item {
        public let color: AdaptyUI.Color
        public let p: Double
    }

    public enum Kind {
        case linear
        case conic
        case radial
    }
}
