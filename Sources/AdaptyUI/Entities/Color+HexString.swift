//
//  Color+HexString.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 20.01.2023
//  Copyright © 2023 Adapty. All rights reserved.
//

import Foundation

extension AdaptyUI.Color {
    public var asHexString: String { String(format: "#%08x", data) }

    public init(hex: String) throws {
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
            self.init(data: hexNumber)
        } else if hexColor.count == 6 {
            hexNumber = (hexNumber << 8) | 0x000000FF
            self.init(data: hexNumber)
        } else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: "Wrong format of hex color string, number of hex pairs should be 3 or 4"))
        }
    }
}
