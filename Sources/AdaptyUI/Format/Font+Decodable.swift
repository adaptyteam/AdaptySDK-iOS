//
//  Font+Decodable.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 20.01.2023
//  Copyright © 2023 Adapty. All rights reserved.
//

import Foundation

extension AdaptyUI.Font: Decodable {
    enum CodingKeys: String, CodingKey {
        case alias = "value"
        case familyName = "family_name"
        case weight
        case italic
//        case style // Deprecated
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
            familyName = (try container.decodeIfPresent(String.self, forKey: .familyName)) ?? "adapty_system"
        }
        weight = try container.decodeIfPresent(Int.self, forKey: .weight)
        italic = (try container.decodeIfPresent(Bool.self, forKey: .italic)) ?? false
        defaultSize = try container.decodeIfPresent(Double.self, forKey: .defaultSize)
        defaultColor = try container.decodeIfPresent(AdaptyUI.Color.self, forKey: .defaultColor)
        defaultHorizontalAlign = try container.decodeIfPresent(AdaptyUI.HorizontalAlign.self, forKey: .defaultHorizontalAlign)
    }
}
