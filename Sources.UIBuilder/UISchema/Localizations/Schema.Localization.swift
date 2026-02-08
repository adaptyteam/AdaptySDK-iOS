//
//  Schema.Localization.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 19.01.2023
//

import Foundation

extension Schema {
    struct Localization: Sendable, Hashable {
        let id: LocaleId
        let isRightToLeft: Bool?
        let strings: [StringIdentifier: Item]?
        let assets: [AssetIdentifier: Asset]?

        struct Item: Sendable, Hashable {
            let value: RichText
            let fallback: RichText?
        }
    }
}

extension Schema.Localization: Codable {
    enum CodingKeys: String, CodingKey {
        case id
        case strings
        case assets
        case isRightToLeft = "is_right_to_left"
    }

    enum ItemCodingKeys: String, CodingKey {
        case id
        case value
        case fallback
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(LocaleId.self, forKey: .id)
        isRightToLeft = try container.decodeIfPresent(Bool.self, forKey: .isRightToLeft)

        assets = try (container.decodeIfPresent(Schema.AssetsCollection.self, forKey: .assets))?.value

        var stringsContainer = try container.nestedUnkeyedContainer(forKey: .strings)
        var strings = [Schema.StringIdentifier: Item]()
        if let count = stringsContainer.count {
            strings.reserveCapacity(count)
        }
        while !stringsContainer.isAtEnd {
            let item = try stringsContainer.nestedContainer(keyedBy: ItemCodingKeys.self)
            try strings[item.decode(Schema.StringIdentifier.self, forKey: .id)] = try Item(
                value: item.decode(Schema.RichText.self, forKey: .value),
                fallback: item.decodeIfPresent(Schema.RichText.self, forKey: .fallback)
            )
        }
        self.strings = strings.nonEmptyOrNil
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encodeIfPresent(isRightToLeft, forKey: .isRightToLeft)

        if let assets = assets.nonEmptyOrNil {
            try container.encode(Schema.AssetsCollection(value: assets), forKey: .assets)
        }

        if let strings {
            for (key, item) in strings {
                var stringsContainer = container.nestedUnkeyedContainer(forKey: .strings)
                var itemContainer = stringsContainer.nestedContainer(keyedBy: ItemCodingKeys.self)
                try itemContainer.encode(key, forKey: .id)
                try itemContainer.encode(item.value, forKey: .value)
                try itemContainer.encodeIfPresent(item.fallback, forKey: .fallback)
            }
        }
    }
}
