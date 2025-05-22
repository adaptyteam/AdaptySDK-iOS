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
    static let profileId = CodingUserInfoKey(rawValue: "adapty_profile_id")!
    static let placementId = CodingUserInfoKey(rawValue: "adapty_placement_id")!
    static let placementVariationId = CodingUserInfoKey(rawValue: "adapty_placement_variation_id")!
    static let placement = CodingUserInfoKey(rawValue: "adapty_placement")!
}

extension CodingUserInfoContainer {
    func setProfileId(_ value: String) {
        userInfo[.profileId] = value
    }

    func setPlacement(_ value: AdaptyPlacement) {
        userInfo[.placement] = value
    }

    func setPlacementId(_ value: String) {
        userInfo[.placementId] = value
    }

    func setPlacementVariationId(_ value: String) {
        userInfo[.placementVariationId] = value
    }

    package func enableEncodingViewConfiguration() {
        userInfo[.enableEncodingViewConfiguration] = true
    }
}

extension [CodingUserInfoKey: Any] {
    var enabledEncodingViewConfiguration: Bool {
        self[.enableEncodingViewConfiguration] as? Bool ?? false
    }

    var profileId: String {
        get throws {
            if let value = self[.profileId] as? String {
                return value
            }

            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: "The decoder does not have the \(CodingUserInfoKey.profileId) parameter"))
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

extension Encoder {
    func backendContainer<Key: CodingKey>(type: String, keyedBy: Key.Type) throws -> KeyedEncodingContainer<Key> {
        var container = container(keyedBy: Backend.CodingKeys.self)
        var dataObject = container.nestedContainer(keyedBy: Backend.CodingKeys.self, forKey: .data)
        try dataObject.encode(type, forKey: .type)
        return dataObject.nestedContainer(keyedBy: Key.self, forKey: .attributes)
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

    struct Meta<Value>: Sendable, Decodable where Value: Decodable, Value: Sendable {
        let value: Value

        init(from decoder: Decoder) throws {
            value = try decoder
                .container(keyedBy: Backend.CodingKeys.self)
                .decode(Value.self, forKey: .meta)
        }
    }
}
