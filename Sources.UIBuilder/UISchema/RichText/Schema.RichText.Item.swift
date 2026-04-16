//
//  Schema.RichText.Item.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 09.01.2026.
//

import Foundation

extension Schema.RichText {
    typealias Item = VC.RichText.Item
}

extension Schema.RichText.Item: Decodable {
    enum CodingKeys: String, CodingKey {
        case text
        case tag
        case image
        case attributes
        case action
    }

    init(from decoder: Decoder) throws {
        if let value = try? (try? decoder.singleValueContainer())?.decode(String.self) {
            self = .text(value, nil, nil)
            return
        }

        let container = try decoder.container(keyedBy: CodingKeys.self)
        self =
            if container.contains(.text) {
                try .text(
                    container.decode(String.self, forKey: .text),
                    container.decodeIfPresent(Schema.RichText.Attributes.self, forKey: .attributes),
                    container.decodeIfPresent(Schema.Action.self, forKey: .action)
                )
            } else if container.contains(.tag) {
                try .tag(
                    container.decode(String.self, forKey: .tag),
                    container.decodeIfPresent(Schema.RichText.Attributes.self, forKey: .attributes),
                    container.decodeIfPresent(Schema.Action.self, forKey: .action)
                )
            } else if container.contains(.image) {
                try .image(
                    container.decode(Schema.AssetReference.self, forKey: .image),
                    container.decodeIfPresent(Schema.RichText.Attributes.self, forKey: .attributes)
                )
            } else {
                .unknown
            }
    }
}

