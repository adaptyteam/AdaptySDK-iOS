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
        case converter
        case format
    }

    init(from decoder: Decoder) throws {
        if let value = try? (try? decoder.singleValueContainer())?.decode(String.self) {
            self = .text(value, nil, nil)
            return
        }

        let container = try decoder.container(keyedBy: CodingKeys.self)

        if container.contains(.text) {
            self = try .text(
                container.decode(String.self, forKey: .text),
                container.decodeIfPresent(Schema.RichText.Attributes.self, forKey: .attributes),
                container.decodeIfPresent(Schema.Action.self, forKey: .action)
            )
        } else if container.contains(.tag) {
            let tag = try container.decode(String.self, forKey: .tag)

            let converter: Schema.AnyConverter? =
                if container.exist(.converter) {
                    try Schema.AnyConverter.forTag(from: decoder)
                } else if tag == "PERCENT", container.exist(.format)  {
                    try? Schema.PercentConverter(from: decoder).asAnyConverter
                } else {
                    nil
                }

            self = try .tag(
                tag,
                container.decodeIfPresent(Schema.RichText.Attributes.self, forKey: .attributes),
                converter,
                container.decodeIfPresent(Schema.Action.self, forKey: .action)
            )
        } else if container.contains(.image) {
            self = try .image(
                container.decode(Schema.AssetReference.self, forKey: .image),
                container.decodeIfPresent(Schema.RichText.Attributes.self, forKey: .attributes)
            )
        } else {
            self = .unknown
        }
    }
}

