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
        let id: String
        let strings: [String: String]?
        let assets: [String: Asset]?
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
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)

        assets = (try container.decodeIfPresent(AdaptyUI.Assets.self, forKey: .assets))?.value

        var stringsContainer = try container.nestedUnkeyedContainer(forKey: .strings)
        var strings = [String: String]()
        if let count = stringsContainer.count {
            strings.reserveCapacity(count)
        }
        while !stringsContainer.isAtEnd {
            let item = try stringsContainer.nestedContainer(keyedBy: ItemCodingKeys.self)
            strings[try item.decode(String.self, forKey: .id)] = try item.decode(String.self, forKey: .value)
        }
        self.strings = strings.isEmpty ? nil : strings
    }
}
