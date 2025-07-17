//
//  Color.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 19.01.2023
//

import Foundation

package extension AdaptyViewConfiguration {
    struct Color: CustomAsset, Sendable, Hashable {
        static let transparent = Color(customId: nil, data: 0x00000000)
        static let white = Color(customId: nil, data: 0xFFFFFFFF)
        static let lightGray = Color(customId: nil, data: 0xD3D3D3FF)
        static let black = Color(customId: nil, data: 0x000000FF)

        package let customId: String?
        let data: UInt64

        package var red: Double { Double((data & 0xFF000000) >> 24) / 255 }
        package var green: Double { Double((data & 0x00FF0000) >> 16) / 255 }
        package var blue: Double { Double((data & 0x0000FF00) >> 8) / 255 }
        package var alpha: Double { Double(data & 0x000000FF) / 255 }
    }
}

#if DEBUG
package extension AdaptyViewConfiguration.Color {
    static func create(customId: String? = nil, data: UInt64) -> Self {
        .init(customId: customId, data: data)
    }
}
#endif

extension AdaptyViewConfiguration.Color: Codable {
    static let assetType = "color"

    package init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let hex = try container.decode(String.self)
        try self.init(customId: nil, hex: hex)
    }

    package func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(asHexString)
    }
}
