//
//  VC.Color+HexString.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 20.01.2023
//

import Foundation

package extension VC.Color {
    var asHexString: String { String(format: "#%08x", data) }

    init(customId: String?, hex: String) throws {
        guard hex.hasPrefix("#") else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: "Wrong format of hex color string, don`t found prefix '#'"))
        }

        let hexColor = String(hex[hex.index(hex.startIndex, offsetBy: 1)...])
        let scanner = Scanner(string: hexColor)
        var hexNumber: UInt64 = 0
        guard scanner.scanHexInt64(&hexNumber) else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: "Wrong format of hex color string"))
        }

        if hexColor.count == 8 {
            self.init(customId: customId, data: hexNumber)
        } else if hexColor.count == 6 {
            hexNumber = (hexNumber << 8) | 0x000000FF
            self.init(customId: customId, data: hexNumber)
        } else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: "Wrong format of hex color string, number of hex pairs should be 3 or 4"))
        }
    }
}
