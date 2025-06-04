//
//  AdaptyRemoteConfig.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 06.04.2024
//

import Foundation

public struct AdaptyRemoteConfig: Sendable {
    let adaptyLocale: AdaptyLocale

    public var locale: String { adaptyLocale.id }
    /// A custom JSON string configured in Adapty Dashboard for this paywall.
    public let jsonString: String
    /// A custom dictionary configured in Adapty Dashboard for this paywall (same as `jsonString`)
    public var dictionary: [String: Any]? {
        guard let data = jsonString.data(using: .utf8),
              let remoteConfig = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        else { return nil }
        return remoteConfig
    }
}

extension AdaptyRemoteConfig: CustomStringConvertible {
    public var description: String {
        "(locale: \(locale), jsonString: \(jsonString))"
    }
}

extension AdaptyRemoteConfig: Codable {
    enum CodingKeys: String, CodingKey {
        case adaptyLocale = "lang"
        case jsonString = "data"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        adaptyLocale = try container.decode(AdaptyLocale.self, forKey: .adaptyLocale)
        jsonString = try container.decode(String.self, forKey: .jsonString)
    }
}
