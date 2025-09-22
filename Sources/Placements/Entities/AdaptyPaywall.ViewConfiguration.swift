//
//  AdaptyPaywall.ViewConfiguration.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 10.04.2024
//
//

import AdaptyUIBuider
import Foundation

extension AdaptyPaywall {
    struct ViewConfiguration: Sendable {
        let id: String
        let responseLocale: AdaptyLocale
        let schemaOrJson: SchemaOrJson?
        enum SchemaOrJson: Sendable {
            case value(AdaptyUISchema)
            case json(Data)
        }
    }
}

extension AdaptyPaywall.ViewConfiguration: CustomStringConvertible {
    package var description: String {
        switch schemaOrJson {
        case nil:
            "(id: \(id), schema: nil)"
        case let .value(schema):
            "(id: \(id), schema: \(schema))"
        case .json:
            "(id: \(id), schema: json"
        }
    }
}

extension AdaptyPaywall.ViewConfiguration {
    var schema: AdaptyUISchema? {
        get throws(AdaptyError) {
            switch schemaOrJson {
            case nil:
                return nil
            case let .value(value):
                return value
            case let .json(data):
                do {
                    return try Storage.decoder.decode(AdaptyUISchema.self, from: data)
                } catch {
                    throw .decodingViewConfiguration(error)
                }
            }
        }
    }
}

extension AdaptyPaywall.ViewConfiguration: Codable {
    enum CodingKeys: String, CodingKey {
        case value = "paywall_builder_config"
        case json
        case responseLocale = "lang"
        case id = "paywall_builder_id"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        responseLocale = try container.decode(AdaptyLocale.self, forKey: .responseLocale)

        if container.contains(.value) {
            schemaOrJson = try .value(container.decode(AdaptyUISchema.self, forKey: .value))
        } else if container.contains(.json) {
            guard let data = try container.decode(String.self, forKey: .json).data(using: .utf8) else {
                throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Invalid property \(CodingKeys.json.rawValue)"))
            }
            schemaOrJson = .json(data)

        } else {
            schemaOrJson = nil
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(responseLocale, forKey: .responseLocale)
        try container.encode(id, forKey: .id)

        guard let schemaOrJson = schemaOrJson, encoder.userInfo.enabledEncodingViewConfiguration else { return }
        let data: Data =
            switch schemaOrJson {
            case let .json(value):
                value
            case let .value(value):
                try Storage.encoder.encode(value)
            }
        guard let json = String(data: data, encoding: .utf8) else {
            throw EncodingError.invalidValue(data, EncodingError.Context(codingPath: encoder.codingPath, debugDescription: "Invalid property \(CodingKeys.json.rawValue)"))
        }
        try container.encode(json, forKey: .json)
    }
}
