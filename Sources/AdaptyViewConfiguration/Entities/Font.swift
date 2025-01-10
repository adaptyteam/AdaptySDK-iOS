//
//  Font.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 19.01.2023
//

import Foundation

package extension AdaptyViewConfiguration {
    struct Font: Sendable, Hashable {
        static let defaultFontColor = Color.black
        package static let `default` = Font(
            alias: "adapty_system",
            familyName: "adapty_system",
            weight: 400,
            italic: false,
            defaultSize: 15,
            defaultColor: .solidColor(defaultFontColor)
        )

        package let alias: String
        package let familyName: String
        package let weight: Int
        package let italic: Bool
        let defaultSize: Double
        let defaultColor: Filling
    }
}

#if DEBUG
    package extension AdaptyViewConfiguration.Font {
        static func create(
            alias: String = `default`.alias,
            familyName: String = `default`.familyName,
            weight: Int = `default`.weight,
            italic: Bool = `default`.italic,
            defaultSize: Double = `default`.defaultSize,
            defaultColor: AdaptyViewConfiguration.Filling = `default`.defaultColor
        ) -> Self {
            .init(
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

extension AdaptyViewConfiguration.Font: Codable {
    static let assetType = "font"

    enum CodingKeys: String, CodingKey {
        case type
        case alias = "value"
        case familyName = "family_name"
        case weight
        case italic
        case defaultSize = "size"
        case defaultColor = "color"
    }

    package init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let v = (try? container.decode([String].self, forKey: .alias))?.first {
            alias = v
        } else {
            alias = try container.decode(String.self, forKey: .alias)
        }
        if let v = (try? container.decode([String].self, forKey: .familyName))?.first {
            familyName = v
        } else {
            familyName = try container.decodeIfPresent(String.self, forKey: .familyName) ?? AdaptyViewConfiguration.Font.default.familyName
        }
        weight = try container.decodeIfPresent(Int.self, forKey: .weight) ?? AdaptyViewConfiguration.Font.default.weight
        italic = try container.decodeIfPresent(Bool.self, forKey: .italic) ?? AdaptyViewConfiguration.Font.default.italic

        defaultSize = try container.decodeIfPresent(Double.self, forKey: .defaultSize) ?? AdaptyViewConfiguration.Font.default.defaultSize

        defaultColor = try container.decodeIfPresent(AdaptyViewConfiguration.Color.self, forKey: .defaultColor).map { .solidColor($0) } ?? AdaptyViewConfiguration.Font.default.defaultColor
    }

    package func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(Self.assetType, forKey: .type)

        try container.encode(alias, forKey: .alias)
        if familyName != AdaptyViewConfiguration.Font.default.familyName {
            try container.encode(familyName, forKey: .familyName)
        }
        if weight != AdaptyViewConfiguration.Font.default.weight {
            try container.encode(weight, forKey: .weight)
        }
        if italic != AdaptyViewConfiguration.Font.default.italic {
            try container.encode(italic, forKey: .italic)
        }
        if defaultSize != AdaptyViewConfiguration.Font.default.defaultSize {
            try container.encode(defaultSize, forKey: .defaultSize)
        }
        if case let .solidColor(color) = defaultColor, AdaptyViewConfiguration.Font.defaultFontColor != color {
            try container.encode(color, forKey: .defaultColor)
        }
    }
}
