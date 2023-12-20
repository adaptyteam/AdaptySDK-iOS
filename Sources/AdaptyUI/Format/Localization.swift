//
//  Localization.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 19.01.2023
//  Copyright © 2023 Adapty. All rights reserved.
//

import Foundation

extension AdaptyUI {
    struct Localization {
        let id: AdaptyLocale
        let strings: [String: Item]?
        let assets: [String: Asset]?

        struct Item {
            let value: String
            let fallback: String?
            let hasTags: Bool
        }
    }
}

extension AdaptyUI.Localization: Decodable {
    enum CodingKeys: String, CodingKey {
        case id
        case strings
        case assets
    }

    enum ItemCodingKeys: String, CodingKey {
        case id
        case value
        case fallback
        case hasTags = "has_tags"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(AdaptyLocale.self, forKey: .id)

        assets = (try container.decodeIfPresent(AdaptyUI.Assets.self, forKey: .assets))?.value

        var stringsContainer = try container.nestedUnkeyedContainer(forKey: .strings)
        var strings = [String: Item]()
        if let count = stringsContainer.count {
            strings.reserveCapacity(count)
        }
        while !stringsContainer.isAtEnd {
            let item = try stringsContainer.nestedContainer(keyedBy: ItemCodingKeys.self)
            strings[try item.decode(String.self, forKey: .id)] = Item(
                value: try item.decode(String.self, forKey: .value),
                fallback: try item.decodeIfPresent(String.self, forKey: .fallback),
                hasTags: (try item.decodeIfPresent(Bool.self, forKey: .hasTags)) ?? false
            )
        }
        self.strings = strings.isEmpty ? nil : strings
    }
}
