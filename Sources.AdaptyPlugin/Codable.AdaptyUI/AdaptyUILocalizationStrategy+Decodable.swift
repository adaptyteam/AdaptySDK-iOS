//
//  AdaptyUILocalizationStrategy+Decodable.swift
//  AdaptyPlugin
//
//  Created by Aleksei Valiano on 18.11.2026.
//

import AdaptyUIBuilder
import Foundation

extension AdaptyUILocalizationStrategy: Decodable {
    enum CodingKeys: String, CodingKey {
        case resolver
        case customId = "custom_id"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let value = try container.decode(String.self, forKey: .resolver)

        guard let resolver = AdaptyUILocalizationResolver(rawValue: value) else {
            throw DecodingError.dataCorruptedError(forKey: .resolver, in: container, debugDescription: "Unsupported localization resolver: \(value)")
        }

        if let customId = try container.decodeIfPresent(String.self, forKey: .customId) {
            self.init(resolver, custom: AdaptyUIPluginLocalizationResolver(id: customId))
        } else {
            self.init(resolver)
        }
    }
}
