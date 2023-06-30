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
        case name = "value"
        case style
        case defaultSize = "size"
        case defaultColor = "color"
        case defaultHorizontalAlign = "horizontal_align"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        style = try container.decode(String.self, forKey: .style)
        defaultSize = try container.decodeIfPresent(Double.self, forKey: .defaultSize)
        defaultColor = try container.decodeIfPresent(AdaptyUI.Color.self, forKey: .defaultColor)
        defaultHorizontalAlign = try container.decodeIfPresent(AdaptyUI.HorizontalAlign.self, forKey: .defaultHorizontalAlign)
    }
}
