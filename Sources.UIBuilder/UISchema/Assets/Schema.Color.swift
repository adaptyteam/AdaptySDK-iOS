//
//  Schema.Color.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 25.11.2025.
//

import Foundation

extension Schema {
    typealias Color = VC.Color
}

extension Schema.Color {
    static let transparent = Self(customId: nil, data: 0x00000000)
    static let white = Self(customId: nil, data: 0xFFFFFFFF)
    static let lightGray = Self(customId: nil, data: 0xD3D3D3FF)
    static let black = Self(customId: nil, data: 0x000000FF)
}

extension Schema.Color {
    static let assetType = "color"

    static func assetType(_ type: String) -> Bool {
        type == assetType
    }
}

extension Schema.Color: RawRepresentable {
    package init?(rawValue hex: String) {
        guard hex.hasPrefix("#") else { return nil }

        let hexColor = String(hex[hex.index(hex.startIndex, offsetBy: 1)...])
        let scanner = Scanner(string: hexColor)
        var hexNumber: UInt64 = 0
        guard scanner.scanHexInt64(&hexNumber) else { return nil }

        if hexColor.count == 8 {
            self.init(customId: nil, data: hexNumber)
        } else if hexColor.count == 6 {
            hexNumber = (hexNumber << 8) | 0x000000FF
            self.init(customId: nil, data: hexNumber)
        } else {
            return nil
        }
    }

    package var rawValue: String {
        String(format: "#%08x", data)
    }
}

extension Schema.Color: Codable {}
