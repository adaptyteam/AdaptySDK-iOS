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

private extension CodingUserInfoKey {
    static let enableEncodingViewConfiguration = CodingUserInfoKey(rawValue: "adapty_encode_view_configuration")!
    static let userId = CodingUserInfoKey(rawValue: "adapty_user_id")!
    static let placementId = CodingUserInfoKey(rawValue: "adapty_placement_id")!
    static let placementVariationId = CodingUserInfoKey(rawValue: "adapty_placement_variation_id")!
    static let placement = CodingUserInfoKey(rawValue: "adapty_placement")!
    static let requestlocale = CodingUserInfoKey(rawValue: "adapty_request_locale")!
}

extension CodingUserInfo {
    mutating func setUserId(_ value: AdaptyUserId) {
        self[.userId] = value
    }

    mutating func setPlacement(_ value: AdaptyPlacement) {
        self[.placement] = value
    }

    mutating func setPlacementId(_ value: String) {
        self[.placementId] = value
    }

    mutating func setRequestLocale(_ value: AdaptyLocale) {
        self[.requestlocale] = value
    }

    mutating func setPlacementVariationId(_ value: String) {
        self[.placementVariationId] = value
    }

    package mutating func enableEncodingViewConfiguration() {
        self[.enableEncodingViewConfiguration] = true
    }
}

extension [CodingUserInfoKey: Any] {
    var enabledEncodingViewConfiguration: Bool {
        self[.enableEncodingViewConfiguration] as? Bool ?? false
    }

    var userId: AdaptyUserId {
        get throws {
            if let value = self[.userId] as? AdaptyUserId {
                return value
            }

            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: "The decoder does not have the \(CodingUserInfoKey.userId) parameter"))
        }
    }

    var placementId: String {
        get throws {
            if let value = self[.placementId] as? String {
                return value
            }
            if let value = placementOrNil {
                return value.id
            }
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: "The decoder does not have the \(CodingUserInfoKey.placementId) parameter"))
        }
    }

    var placement: AdaptyPlacement {
        get throws {
            if let value = placementOrNil {
                return value
            }

            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: "The decoder does not have the \(CodingUserInfoKey.placement) parameter"))
        }
    }

    var placementOrNil: AdaptyPlacement? {
        self[.placement] as? AdaptyPlacement
    }

    var requestLocaleOrNil: AdaptyLocale? {
        self[.requestlocale] as? AdaptyLocale
    }

    var placementVariationIdOrNil: String? {
        self[.placementVariationId] as? String
    }
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
    struct Data<Value>: Sendable, Decodable where Value: Decodable, Value: Sendable {
        let value: Value

        init(from decoder: Decoder) throws {
            value = try decoder
                .container(keyedBy: Backend.CodingKeys.self)
                .decode(Value.self, forKey: .data)
        }
    }

    struct OptionalData<Value>: Sendable, Decodable where Value: Decodable, Value: Sendable {
        let value: Value?

        init(from decoder: Decoder) throws {
            value = try decoder
                .container(keyedBy: Backend.CodingKeys.self)
                .decodeIfPresent(Value.self, forKey: .data)
        }
    }

    struct Meta<Value>: Sendable, Decodable where Value: Decodable, Value: Sendable {
        let value: Value

        init(from decoder: Decoder) throws {
            value = try decoder
                .container(keyedBy: Backend.CodingKeys.self)
                .decode(Value.self, forKey: .meta)
        }
    }
}
