//
//  Backend+Codable.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 08.09.2022.
//

import Foundation

extension Backend {
    static func configure(jsonDecoder: JSONDecoder) {
        jsonDecoder.dateDecodingStrategy = .formatted(Backend.dateFormatter)
        jsonDecoder.dataDecodingStrategy = .base64
    }

    static func configure(jsonEncoder: JSONEncoder) {
        jsonEncoder.dateEncodingStrategy = .formatted(Backend.inUTCDateFormatter)
        jsonEncoder.dataEncodingStrategy = .base64
    }

    package static let inUTCDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        return formatter
    }()

    package static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        return formatter
    }()
}

extension Backend {
    enum CodingKeys: String, CodingKey {
        case data
        case type
        case id
        case attributes
        case meta
    }
}

extension Backend.Response {
    struct Data<Value: Sendable>: Sendable {
        let value: Value
    }

    struct OptionalData<Value: Decodable & Sendable>: Sendable, Decodable {
        let value: Value?

        init(from decoder: Decoder) throws {
            value = try decoder
                .container(keyedBy: Backend.CodingKeys.self)
                .decodeIfPresent(Value.self, forKey: .data)
        }
    }

    struct Meta<Value: Decodable & Sendable>: Sendable, Decodable {
        let value: Value

        init(from decoder: Decoder) throws {
            value = try decoder
                .container(keyedBy: Backend.CodingKeys.self)
                .decode(Value.self, forKey: .meta)
        }
    }
}

extension Backend.Response.Data: Decodable where Value: Decodable {
    init(from decoder: Decoder) throws {
        value = try decoder
            .container(keyedBy: Backend.CodingKeys.self)
            .decode(Value.self, forKey: .data)
    }
}

extension Backend.Response.Data: DecodableWithConfiguration where Value: DecodableWithConfiguration {
    typealias DecodingConfiguration = Value.DecodingConfiguration

    init(from decoder: Decoder, configuration: DecodingConfiguration) throws {
        value = try decoder
            .container(keyedBy: Backend.CodingKeys.self)
            .decode(Value.self, forKey: .data, configuration: configuration)
    }
}

