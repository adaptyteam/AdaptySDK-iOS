//
//  Font.swift
//  AdaptyUI
//
//  Created by Aleksei Valiano on 19.01.2023
//

import Foundation

extension AdaptyUICore {
    package struct Font: Sendable, Hashable {
        package static let `default` = Font(
            alias: "adapty_system",
            familyName: "adapty_system",
            weight: 400,
            italic: false,
            defaultSize: 15,
            defaultColor: .solidColor(.black)
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
    package extension AdaptyUICore.Font {
        static func create(
            alias: String = `default`.alias,
            familyName: String = `default`.familyName,
            weight: Int = `default`.weight,
            italic: Bool = `default`.italic,
            defaultSize: Double = `default`.defaultSize,
            defaultColor: AdaptyUICore.Filling = `default`.defaultColor
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

extension AdaptyUICore.Font: Decodable {
    static let assetType = "font"
    
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
            familyName = try container.decodeIfPresent(String.self, forKey: .familyName) ?? AdaptyUICore.Font.default.familyName
        }
        weight = try container.decodeIfPresent(Int.self, forKey: .weight) ?? AdaptyUICore.Font.default.weight
        italic = try container.decodeIfPresent(Bool.self, forKey: .italic) ?? AdaptyUICore.Font.default.italic

        defaultSize = try container.decodeIfPresent(Double.self, forKey: .defaultSize) ?? AdaptyUICore.Font.default.defaultSize

        defaultColor = try container.decodeIfPresent(AdaptyUICore.Color.self, forKey: .defaultColor).map { .solidColor($0) } ?? AdaptyUICore.Font.default.defaultColor
    }
}
