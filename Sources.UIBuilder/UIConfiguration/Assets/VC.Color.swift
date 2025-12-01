//
//  VC.Color.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 19.01.2023
//

import Foundation

package extension VC {
    struct Color: CustomAsset, Sendable, Hashable {
        package let customId: String?
        let data: UInt64
    }
}

package extension VC.Color {
    var red: Double { Double((data & 0xFF000000) >> 24) / 255 }
    var green: Double { Double((data & 0x00FF0000) >> 16) / 255 }
    var blue: Double { Double((data & 0x0000FF00) >> 8) / 255 }
    var alpha: Double { Double(data & 0x000000FF) / 255 }
}

extension VC.Color {
    static let transparent = Self(customId: nil, data: 0x00000000)
    static let white = Self(customId: nil, data: 0xFFFFFFFF)
    static let lightGray = Self(customId: nil, data: 0xD3D3D3FF)
    static let black = Self(customId: nil, data: 0x000000FF)
}

#if DEBUG
package extension VC.Color {
    static func create(
        customId: String? = nil,
        data: UInt64
    ) -> Self {
        .init(
            customId: customId,
            data: data
        )
    }
}
#endif
