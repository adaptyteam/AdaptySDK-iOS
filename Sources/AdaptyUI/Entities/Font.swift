//
//  Font.swift
//  AdaptyUI
//
//  Created by Aleksei Valiano on 19.01.2023
//

import Foundation

extension AdaptyUI {
    package struct Font {
        package static let `default` = Font(
            alias: "adapty_system",
            familyName: "adapty_system",
            weight: 400,
            italic: false,
            defaultSize: 15,
            defaultColor: .color(AdaptyUI.Color.black)
        )

        package let alias: String
        package let familyName: String
        package let weight: Int
        package let italic: Bool
        let defaultSize: Double
        let defaultColor: AdaptyUI.ColorFilling
    }
}

#if DEBUG
    package extension AdaptyUI.Font {
        static func create(
            alias: String = `default`.alias,
            familyName: String = `default`.familyName,
            weight: Int = `default`.weight,
            italic: Bool = `default`.italic,
            defaultSize: Double = `default`.defaultSize,
            defaultColor: AdaptyUI.ColorFilling = `default`.defaultColor
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

extension AdaptyUI.Font: Decodable {
    enum CodingKeys: String, CodingKey {
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
            familyName = try container.decodeIfPresent(String.self, forKey: .familyName) ?? AdaptyUI.Font.default.familyName
        }
        weight = try container.decodeIfPresent(Int.self, forKey: .weight) ?? AdaptyUI.Font.default.weight
        italic = try container.decodeIfPresent(Bool.self, forKey: .italic) ?? AdaptyUI.Font.default.italic

        defaultSize = try container.decodeIfPresent(Double.self, forKey: .defaultSize) ?? AdaptyUI.Font.default.defaultSize
  
        defaultColor = try container.decodeIfPresent(AdaptyUI.Color.self, forKey: .defaultColor).map { .color($0) } ?? AdaptyUI.Font.default.defaultColor
    }
}
