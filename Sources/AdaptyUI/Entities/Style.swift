//
//  Style.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 20.01.2023
//  Copyright © 2023 Adapty. All rights reserved.
//

import Foundation

extension AdaptyUI {
    struct Style {
        let common: [String: AdaptyUI.ViewItem]?
        let custom: [String: AdaptyUI.ViewItem]?
    }
}

extension AdaptyUI.Style: Decodable {
    enum CodingKeys: String, CodingKey {
        case customProperties = "custom_properties"
    }

    init(from decoder: Decoder) throws {
        let single = try decoder.singleValueContainer()

        var common = try single.decode([String: AdaptyUI.ViewItem].self)
        common.removeValue(forKey: CodingKeys.customProperties.rawValue)
        self.common = common.isEmpty ? nil : common

        let container = try decoder.container(keyedBy: CodingKeys.self)
        custom = try container.decodeIfPresent([String: AdaptyUI.ViewItem].self, forKey: .customProperties)
    }
}
