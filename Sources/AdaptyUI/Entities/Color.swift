//
//  Color.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 19.01.2023
//  Copyright © 2023 Adapty. All rights reserved.
//

import Foundation

extension AdaptyUI {
    public struct Color {
        let data: UInt64

        public var red: Double { Double((data & 0xFF000000) >> 24) / 255 }
        public var green: Double { Double((data & 0x00FF0000) >> 16) / 255 }
        public var blue: Double { Double((data & 0x0000FF00) >> 8) / 255 }
        public var alpha: Double { Double(data & 0x000000FF) / 255 }
    }
}
