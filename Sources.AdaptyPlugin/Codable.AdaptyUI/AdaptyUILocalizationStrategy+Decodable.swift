//
//  AdaptyUILocalizationStrategy+Decodable.swift
//  AdaptyPlugin
//
//  Created by Aleksei Valiano on 18.11.2026.
//

import AdaptyUIBuilder
import Foundation

extension AdaptyUILocalizationStrategy: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let value = try container.decode(String.self)
        switch value {
        case "default":
            self = .default
        case "system":
            self = .system
        case "legacy":
            self = .legacy
        case "identity":
            self = .identity
        case "":
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Localization strategy must not be empty")
        default:
            // shortcut: host-side custom resolvers are not supported yet; later: `self = .custom(AdaptyUIPluginLocalizationResolver(id: value))`
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Unsupported localization strategy: \(value)")
        }
    }
}
