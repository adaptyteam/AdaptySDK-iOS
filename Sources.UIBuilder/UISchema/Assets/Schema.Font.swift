//
//  Schema.Font.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 26.11.2025.
//

import Foundation

extension Schema {
    typealias Font = VC.Font
}

extension Schema.Font {
    static let `default` = Self(
        customId: nil,
        alias: "adapty_system",
        familyName: "adapty_system",
        weight: 400,
        italic: false,
        defaultSize: 15,
        defaultColor: .black
    )
}

extension Schema.Font {
    static let assetType = "font"

    static func assetType(_ type: String) -> Bool {
        type == assetType
    }
}

extension Schema.Font: Codable {
    private enum CodingKeys: String, CodingKey {
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
            familyName = try container.decodeIfPresent(String.self, forKey: .familyName) ?? Self.default.familyName
        }
        weight = try container.decodeIfPresent(Int.self, forKey: .weight) ?? Self.default.weight
        italic = try container.decodeIfPresent(Bool.self, forKey: .italic) ?? Self.default.italic

        defaultSize = try container.decodeIfPresent(Double.self, forKey: .defaultSize) ?? Self.default.defaultSize

        defaultColor = try container.decodeIfPresent(Schema.Color.self, forKey: .defaultColor) ?? Self.default.defaultColor
    }

    package func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(Self.assetType, forKey: .type)

        try container.encodeIfPresent(customId, forKey: .customId)

        try container.encode(alias, forKey: .alias)
        if familyName != Self.default.familyName {
            try container.encode(familyName, forKey: .familyName)
        }
        if weight != Self.default.weight {
            try container.encode(weight, forKey: .weight)
        }
        if italic != Self.default.italic {
            try container.encode(italic, forKey: .italic)
        }
        if defaultSize != Self.default.defaultSize {
            try container.encode(defaultSize, forKey: .defaultSize)
        }
        if  defaultColor != Self.default.defaultColor
        {
            try container.encode(defaultColor, forKey: .defaultColor)
        }
    }
}
