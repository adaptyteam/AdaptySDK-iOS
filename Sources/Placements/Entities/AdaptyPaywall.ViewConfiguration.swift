//
//  AdaptyPaywall.ViewConfiguration.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 10.04.2024
//
//

import AdaptyUIBuilder
import Foundation

extension AdaptyPaywall {
    struct ViewConfiguration: Sendable {
        let id: String
        let locale: AdaptyLocale
        let schemaOrJson: SchemaOrJson?
        enum SchemaOrJson: Sendable {
            case unpacked(AdaptyUISchema)
            case packed(Data)
        }
    }
}

extension AdaptyPaywall.ViewConfiguration: CustomStringConvertible {
    package var description: String {
        switch schemaOrJson {
        case nil:
            "(id: \(id), schema: nil)"
        case let .unpacked(schema):
            "(id: \(id), schema: \(schema))"
        case .packed:
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
            case let .unpacked(schema):
                return schema
            case let .packed(data):
                do {
                    return try AdaptyUISchema(from: data)
                } catch {
                    throw .decodingViewConfiguration(error)
                }
            }
        }
    }
    
    func has(languageCode otherLocale: AdaptyLocale, orDefault: Bool = false) -> Bool {
        if locale.equalLanguageCode(otherLocale) { return true }
        else if orDefault, locale.equalLanguageCode(.defaultPlacementLocale) { return true }
        else { return false }
    }
}

extension AdaptyPaywall.ViewConfiguration: Codable {
    enum CodingKeys: String, CodingKey {
        case value = "paywall_builder_config"
        case json
        case locale = "lang"
        case id = "paywall_builder_id"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        locale = try container.decode(AdaptyLocale.self, forKey: .locale)

        if container.contains(.value) {
            schemaOrJson = try .unpacked(container.decode(AdaptyUISchema.self, forKey: .value))
        } else if container.contains(.json) {
            guard let data = try container.decode(String.self, forKey: .json).data(using: .utf8) else {
                throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Invalid property \(CodingKeys.json.rawValue)"))
            }
            schemaOrJson = .packed(data)

        } else {
            schemaOrJson = nil
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(locale, forKey: .locale)
        try container.encode(id, forKey: .id)

        guard let schemaOrJson = schemaOrJson, encoder.userInfo.enabledEncodingViewConfiguration else { return }
        let data: Data =
            switch schemaOrJson {
            case let .packed(data):
                data
            case let .unpacked(schema):
                try Storage.encoder.encode(schema)
            }
        guard let json = String(data: data, encoding: .utf8) else {
            throw EncodingError.invalidValue(data, EncodingError.Context(codingPath: encoder.codingPath, debugDescription: "Invalid property \(CodingKeys.json.rawValue)"))
        }
        try container.encode(json, forKey: .json)
    }
}
