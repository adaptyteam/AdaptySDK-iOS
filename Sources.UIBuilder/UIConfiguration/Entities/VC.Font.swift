//
//  VC.Font.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 19.01.2023
//

import Foundation

package extension VC {
    struct Font: CustomAsset, Sendable, Hashable {
        static let defaultFontColor = Color.black
        package static let `default` = Font(
            customId: nil,
            alias: "adapty_system",
            familyName: "adapty_system",
            weight: 400,
            italic: false,
            defaultSize: 15,
            defaultColor: .solidColor(defaultFontColor)
        )
        package let customId: String?
        package let alias: String
        package let familyName: String
        package let weight: Int
        package let italic: Bool
        let defaultSize: Double
        let defaultColor: Filling
    }
}

#if DEBUG
package extension VC.Font {
    static func create(
        customId: String? = `default`.customId,
        alias: String = `default`.alias,
        familyName: String = `default`.familyName,
        weight: Int = `default`.weight,
        italic: Bool = `default`.italic,
        defaultSize: Double = `default`.defaultSize,
        defaultColor: VC.Filling = `default`.defaultColor
    ) -> Self {
        .init(
            customId: customId,
            alias: alias,
            familyName: familyName,
            weight: weight,
            italic: italic,
            defaultSize: defaultSize,
            defaultColor: defaultColor
        )
    }
}
#endif

extension VC.Font: Codable {
    static let assetType = "font"

    enum CodingKeys: String, CodingKey {
        case type
        case customId = "custom_id"
        case alias = "value"
        case familyName = "family_name"
        case weight
        case italic
        case defaultSize = "size"
        case defaultColor = "color"
    }

    package init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        customId = try container.decodeIfPresent(String.self, forKey: .customId)
        if let v = (try? container.decode([String].self, forKey: .alias))?.first {
            alias = v
        } else {
            alias = try container.decode(String.self, forKey: .alias)
        }
        if let v = (try? container.decode([String].self, forKey: .familyName))?.first {
            familyName = v
        } else {
            familyName = try container.decodeIfPresent(String.self, forKey: .familyName) ?? VC.Font.default.familyName
        }
        weight = try container.decodeIfPresent(Int.self, forKey: .weight) ?? VC.Font.default.weight
        italic = try container.decodeIfPresent(Bool.self, forKey: .italic) ?? VC.Font.default.italic

        defaultSize = try container.decodeIfPresent(Double.self, forKey: .defaultSize) ?? VC.Font.default.defaultSize

        defaultColor = try container.decodeIfPresent(VC.Color.self, forKey: .defaultColor).map { .solidColor($0) } ?? VC.Font.default.defaultColor
    }

    package func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(Self.assetType, forKey: .type)

        try container.encodeIfPresent(customId, forKey: .customId)

        try container.encode(alias, forKey: .alias)
        if familyName != VC.Font.default.familyName {
            try container.encode(familyName, forKey: .familyName)
        }
        if weight != VC.Font.default.weight {
            try container.encode(weight, forKey: .weight)
        }
        if italic != VC.Font.default.italic {
            try container.encode(italic, forKey: .italic)
        }
        if defaultSize != VC.Font.default.defaultSize {
            try container.encode(defaultSize, forKey: .defaultSize)
        }
        if case let .solidColor(color) = defaultColor, VC.Font.defaultFontColor != color {
            try container.encode(color, forKey: .defaultColor)
        }
    }
}
