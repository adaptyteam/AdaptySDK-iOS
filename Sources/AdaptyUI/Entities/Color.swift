//
//  Color.swift
//  AdaptyUI
//
//  Created by Aleksei Valiano on 19.01.2023
//

import Foundation

package extension AdaptyUI {
    struct Color: Hashable, Sendable {
        static let transparent = Color(data: 0x00000000)
        static let white = Color(data: 0xFFFFFFFF)
        static let lightGray = Color(data: 0xD3D3D3FF)
        static let black = Color(data: 0x000000FF)

        let data: UInt64

        package var red: Double { Double((data & 0xFF000000) >> 24) / 255 }
        package var green: Double { Double((data & 0x00FF0000) >> 16) / 255 }
        package var blue: Double { Double((data & 0x0000FF00) >> 8) / 255 }
        package var alpha: Double { Double(data & 0x000000FF) / 255 }
    }
}

#if DEBUG
    package extension AdaptyUI.Color {
        static func create(data: UInt64) -> Self {
            .init(data: data)
        }
    }
#endif

extension AdaptyUI.Color: Decodable {
    static let assetType = "color"
    package init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let hex = try container.decode(String.self)
        try self.init(hex: hex)
    }
}
