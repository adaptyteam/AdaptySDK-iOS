//
//  Schema.Localization.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 19.01.2023
//

import Foundation

extension Schema {
    struct Localization: Sendable {
        let id: LocaleId
        let isRightToLeft: Bool?
        let localeIdentificator: String?
        let strings: [StringIdentifier: Item]?
        let assets: [AssetIdentifier: Asset]?

        struct Item: Sendable {
            let value: RichText
            let fallback: RichText?
        }
    }
}

extension Schema.Localization: Decodable {
    enum CodingKeys: String, CodingKey {
        case id
        case strings
        case assets
        case isRightToLeft = "is_right_to_left"
        case localeIdentificator = "ios_locale_id"
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
        localeIdentificator = try container.decodeIfPresent(String.self, forKey: .localeIdentificator)
        assets = try (container.decodeIfPresent(Schema.AssetsCollection.self, forKey: .assets))?.value

        guard container.exist(.strings) else {
            self.strings = nil
            return
        }

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
}
