//
//  Asset.Font.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 19.01.2023
//

import Foundation

extension AdaptyUI {
    public struct Font {
        public let alias: String
        public let familyName: String
        public let weight: Int?
        public let italic: Bool
        public let defaultSize: Double?
        public let defaultColor: AdaptyUI.Color?
        public let defaultHorizontalAlign: AdaptyUI.HorizontalAlign?
    }
}

extension AdaptyUI.Font {
    var defaultFilling: AdaptyUI.Filling? {
        guard let color = defaultColor else { return nil }
        return .color(color)
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
        case defaultHorizontalAlign = "horizontal_align"
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
            familyName = try container.decodeIfPresent(String.self, forKey: .familyName) ?? "adapty_system"
        }
        weight = try container.decodeIfPresent(Int.self, forKey: .weight)
        italic = try container.decodeIfPresent(Bool.self, forKey: .italic) ?? false
        defaultSize = try container.decodeIfPresent(Double.self, forKey: .defaultSize)
        defaultColor = try container.decodeIfPresent(AdaptyUI.Color.self, forKey: .defaultColor)
        defaultHorizontalAlign = try container.decodeIfPresent(AdaptyUI.HorizontalAlign.self, forKey: .defaultHorizontalAlign)
    }
}
