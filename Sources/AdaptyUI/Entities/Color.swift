//
//  Color.swift
//  AdaptyUI
//
//  Created by Aleksei Valiano on 19.01.2023
//

import Foundation

extension AdaptyUI {
    package struct Color {
        static let black = Color(data: 0x000000FF)

        let data: UInt64

        package var red: Double { Double((data & 0xFF000000) >> 24) / 255 }
        package var green: Double { Double((data & 0x00FF0000) >> 16) / 255 }
        package var blue: Double { Double((data & 0x0000FF00) >> 8) / 255 }
        package var alpha: Double { Double(data & 0x000000FF) / 255 }
    }
}
