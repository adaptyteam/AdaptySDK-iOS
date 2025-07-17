//
//  AdaptyInstallationDetails.Payload.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 13.06.2025.
//
import Foundation

public extension AdaptyInstallationDetails {
    struct Payload: Sendable, Hashable {
        public let jsonString: String

        public var dictionary: [String: Any]? {
            guard let data = jsonString.data(using: .utf8),
                  let value = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            else { return nil }
            return value
        }
    }
}

extension AdaptyInstallationDetails.Payload: CustomStringConvertible {
    public var description: String { jsonString }
}

extension AdaptyInstallationDetails.Payload: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        jsonString = try container.decode(String.self)
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(jsonString)
    }
}
