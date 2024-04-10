//
//  Backend+Codable.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 08.09.2022.
//

import Foundation

extension Backend {
    fileprivate static let isBackendCodableUserInfoKey = CodingUserInfoKey(rawValue: "adapty_backend")!

    static func configure(decoder: JSONDecoder) {
        decoder.dateDecodingStrategy = .formatted(Backend.dateFormatter)
        decoder.dataDecodingStrategy = .base64
        decoder.setIsBackend()
    }

    static func configure(encoder: JSONEncoder) {
        encoder.dateEncodingStrategy = .formatted(Backend.inUTCDateFormatter)
        encoder.dataEncodingStrategy = .base64
        encoder.setIsBackend()
    }

    static var inUTCDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        return formatter
    }()

    static var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        return formatter
    }()
}

private extension CodingUserInfoСontainer {
    func setIsBackend() {
        userInfo[Backend.isBackendCodableUserInfoKey] = true
    }
}

extension [CodingUserInfoKey: Any] {
    var isBackend: Bool {
        [Backend.isBackendCodableUserInfoKey] as? Bool ?? false
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
