//
//  Color+Hex.swift
//  Adapty-Demo
//
//  Created by Elena Gordienko on 18.08.22.
//  Copyright © 2022 Adapty. All rights reserved.
//

import Foundation
import SwiftUI

public extension Color {
    init?(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var rgb: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&rgb)
        let alpha, red, green, blue: UInt64
        switch hex.count {
        case 3:
            (alpha, red, green, blue) = (255, (rgb >> 8) * 17, (rgb >> 4 & 0xF) * 17, (rgb & 0xF) * 17)
        case 6:
            (alpha, red, green, blue) = (255, rgb >> 16, rgb >> 8 & 0xFF, rgb & 0xFF)
        case 8:
            (alpha, red, green, blue) = (rgb >> 24, rgb >> 16 & 0xFF, rgb >> 8 & 0xFF, rgb & 0xFF)
        default:
            return nil
        }

        self.init(
            .sRGB,
            red: Double(red) / 255,
            green: Double(green) / 255,
            blue: Double(blue) / 255,
            opacity: Double(alpha) / 255
        )
    }
}
