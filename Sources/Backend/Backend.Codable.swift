//
//  Backend.Codable.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 08.09.2022.
//

import Foundation

extension Backend {
    static func configure(decoder: JSONDecoder) {
        decoder.dateDecodingStrategy = .formatted(Backend.dateFormatter)
        decoder.dataDecodingStrategy = .base64
    }

    static func configure(encoder: JSONEncoder) {
        encoder.dateEncodingStrategy = .formatted(Backend.dateFormatter)
        encoder.dataEncodingStrategy = .base64
    }

    static var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        return formatter
    }()

    static var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        configure(decoder: decoder)
        return decoder
    }

    static var encoder: JSONEncoder {
        let encoder = JSONEncoder()
        configure(encoder: encoder)
        return encoder
    }
}

extension Backend {
    enum CodingKeys: CodingKey {
        case data
        case type
        case id
        case attributes
    }
}

extension Encoder {
    func backendContainer<Key: CodingKey>(type: String, keyedBy: Key.Type) throws -> KeyedEncodingContainer<Key> {
        var container = container(keyedBy: Backend.CodingKeys.self)
        var dataObject = container.nestedContainer(keyedBy: Backend.CodingKeys.self, forKey: .data)
        try dataObject.encode(type, forKey: .type)
        return dataObject.nestedContainer(keyedBy: Key.self, forKey: .attributes)
    }
}

extension Backend.Request {
    static let localeCodeUserInfoKey = CodingUserInfoKey(rawValue: "request_paywall_locale")!
}

extension Backend.Response {
    struct Body<T: Decodable>: Decodable {
        let value: T

        init(_ value: T) {
            self.value = value
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: Backend.CodingKeys.self)
            let dataObject = try container.nestedContainer(keyedBy: Backend.CodingKeys.self, forKey: .data)
            value = try dataObject.decode(T.self, forKey: .attributes)
        }
    }

    struct ValueOfData<T: Decodable>: Decodable {
        let value: T

        init(_ value: T) {
            self.value = value
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: Backend.CodingKeys.self)
            value = try container.decode(T.self, forKey: .data)
        }
    }
}
