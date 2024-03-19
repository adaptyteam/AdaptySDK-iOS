//
//  AdaptyProfile.CustomAttributes.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 26.09.2022.
//

import Foundation

extension AdaptyProfile {
    typealias CustomAttributes = [String: CustomAttributeValue]

    enum CustomAttributeValue {
        case `nil`
        case string(String)
        case float(Double)
    }
}

extension AdaptyProfile.CustomAttributeValue: Equatable, Sendable {}

extension AdaptyProfile.CustomAttributeValue {
    var hasValue: Bool {
        switch self {
        case .nil:
            false
        default:
            true
        }
    }

    var rawValue: Any? {
        switch self {
        case .nil:
            nil
        case let .string(value):
            value
        case let .float(value):
            value
        }
    }

    func validate() -> AdaptyError? {
        switch self {
        case let .string(value):
            (value.isEmpty || value.count > 50) ? .wrongStringValueOfCustomAttribute() : nil
        default:
            nil
        }
    }
}

extension AdaptyProfile.CustomAttributes {
    func convertToSimpleDictionary() -> [String: Any] {
        [String: Any](
            compactMap {
                guard let rawValue = $1.rawValue else { return nil }
                return ($0, rawValue)
            },
            uniquingKeysWith: { $1 }
        )
    }

    static func validateKey(_ key: String) -> AdaptyError? {
        if key.isEmpty || key.count > 30 || key.range(of: ".*[^A-Za-z0-9._-].*", options: .regularExpression) != nil {
            return .wrongKeyOfCustomAttribute()
        }
        return nil
    }

    func validate() -> AdaptyError? {
        if filter({ $1.hasValue }).count > 30 {
            return .wrongCountCustomAttributes()
        }
        return nil
    }
}

extension AdaptyProfile.CustomAttributeValue: Codable {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if container.decodeNil() {
            self = .nil
        } else if let value = try? container.decode(String.self) {
            self = .string(value)
        } else if let value = try? container.decode(Bool.self) {
            self = .float(value ? 1.0 : 0.0)
        } else if let value = try? container.decode(Double.self) {
            self = .float(value)
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Custom attributes support only Double or String")
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .nil:
            try container.encodeNil()
        case let .string(value):
            try container.encode(value)
        case let .float(value):
            try container.encode(value)
        }
    }
}
