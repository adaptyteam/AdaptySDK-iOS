//
//  ColorLinearGradient.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 29.06.2023
//

import Foundation

extension AdaptyUI {
    public struct ColorLinearGradient {
        public let start: Point
        public let end: Point
        public let items: [Item]
    }
}

extension AdaptyUI.ColorLinearGradient {
    public struct Item {
        public let color: AdaptyUI.Color
        public let p: Double
    }
}
