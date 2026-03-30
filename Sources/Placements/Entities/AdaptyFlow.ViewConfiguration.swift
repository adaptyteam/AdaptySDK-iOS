//
//  AdaptyFlow.ViewConfiguration.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 08.02.2026.
//
//

import AdaptyUIBuilder
import Foundation

extension AdaptyFlow {
    struct ViewConfiguration: Sendable {
        let id: String
        let url: URL
        let fallbackUrl: URL?
        let source: Source?

        enum Source: Sendable {
            case unpacked(AdaptyUISchema)
            case packed(Data)
        }
    }
}

extension AdaptyFlow.ViewConfiguration: CustomStringConvertible {
    package var description: String {
        switch source {
        case nil:
            "(id: \(id), schema: nil)"
        case let .unpacked(schema):
            "(id: \(id), schema: \(schema))"
        case .packed:
            "(id: \(id), schema: json"
        }
    }
}

extension AdaptyFlow.ViewConfiguration {
    var schema: AdaptyUISchema? { // TODO: Remove
        get throws(AdaptyError) {
            switch source {
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
}

extension AdaptyFlow.ViewConfiguration: Codable {
    enum CodingKeys: String, CodingKey {
        case unpackedSource = "flow_schema"
        case packedSource = "flow_json"

        case url = "flow_version_config_url"
        case fallbackUrl = "flow_version_fallback_config_url"
        case id = "flow_version_id"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        url = try container.decode(URL.self, forKey: .url)
        fallbackUrl = try container.decodeIfPresent(URL.self, forKey: .fallbackUrl)

        if container.contains(.unpackedSource) {
            source = try .unpacked(container.decode(AdaptyUISchema.self, forKey: .unpackedSource))
        } else if container.contains(.packedSource) {
            guard let data = try container.decode(String.self, forKey: .packedSource).data(using: .utf8) else {
                throw DecodingError.dataCorruptedError(forKey: .packedSource, in: container, debugDescription: "value is not json-string")
            }
            source = .packed(data)
        } else {
            source = nil
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(url, forKey: .url)
        try container.encodeIfPresent(fallbackUrl, forKey: .fallbackUrl)

        guard let source, encoder.userInfo.enabledEncodingViewConfiguration else { return }
        let data: Data =
            switch source {
            case let .packed(data):
                data
            case let .unpacked(schema):
                try Storage.encoder.encode(schema)
            }

        guard let json = String(data: data, encoding: .utf8) else {
            throw
                EncodingError.invalidValue(data, EncodingError.Context(codingPath: encoder.codingPath, debugDescription: "Invalid property \(CodingKeys.packedSource.rawValue)"))
        }
        try container.encode(json, forKey: .packedSource)
    }
}

