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
        defaultColor: .black,
        defaultLetterSpacing: nil,
        defaultLineHeight: nil
    )
}

extension Schema.Font {
    static let assetType = "font"

    static func assetType(_ type: String) -> Bool {
        type == assetType
    }
}

extension Schema.Font: Decodable {
    private enum CodingKeys: String, CodingKey {
        case type
        case customId = "custom_id"
        case alias = "value"
        case familyName = "family_name"
        case weight
        case italic
        case defaultSize = "size"
        case defaultColor = "color"
        case defaultLetterSpacing = "letter_spacing"
        case defaultLineHeight = "line_height"
    }

    init(from decoder: Decoder) throws {
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

        defaultLetterSpacing = try container.decodeIfPresent(Double.self, forKey: .defaultLetterSpacing)
        defaultLineHeight = try container.decodeIfPresent(Double.self, forKey: .defaultLineHeight)
    }
}

