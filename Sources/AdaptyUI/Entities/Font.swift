//
//  Font.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 19.01.2023
//

import Foundation

extension AdaptyUI {
    public struct Font {
        static let `default` = Font(
            alias: "adapty_system",
            familyName: "adapty_system",
            weight: 400,
            italic: false,
            defaultSize: 15,
            defaultFilling: .color(AdaptyUI.Color.black)
        )

        public let alias: String
        public let familyName: String
        public let weight: Int
        public let italic: Bool
        let defaultSize: Double
        let defaultFilling: AdaptyUI.Filling
    }
}

extension AdaptyUI.Font: Decodable {
    enum CodingKeys: String, CodingKey {
        case alias = "value"
        case familyName = "family_name"
        case weight
        case italic
        case defaultSize = "size"
        case defaultColor = "color"
    }

    public init(from decoder: Decoder) throws {
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
        defaultFilling = try container.decodeIfPresent(AdaptyUI.Color.self, forKey: .defaultColor).map { .color($0) } ?? AdaptyUI.Font.default.defaultFilling
    }
}
