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
    }
}

extension AdaptyUI.Color {
    public var red: Double { Double((data & 0xFF000000) >> 24) / 255 }
    public var green: Double { Double((data & 0x00FF0000) >> 16) / 255 }
    public var blue: Double { Double((data & 0x0000FF00) >> 8) / 255 }
    public var alpha: Double { Double(data & 0x000000FF) / 255 }
}

extension AdaptyUI.Color {
    public var asHexString: String { String(format: "#%08x", data) }

    init(hex: String) throws {
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

extension AdaptyUI.Color: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let hex = try container.decode(String.self)
        try self.init(hex: hex)
    }
}
