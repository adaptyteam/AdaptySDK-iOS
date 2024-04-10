//
//  AdaptyPaywall.RemouteConfig.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 06.04.2024
//
//

import Foundation

extension AdaptyPaywall {
    public struct RemouteConfig {
        let adaptyLocale: AdaptyLocale

        public var locale: String { adaptyLocale.id }
        /// A custom JSON string configured in Adapty Dashboard for this paywall.
        public let jsonString: String?
        /// A custom dictionary configured in Adapty Dashboard for this paywall (same as `jsonString`)
        public lazy var dictionary: [String: Any]? = {
            guard let data = jsonString?.data(using: .utf8),
                  let remoteConfig = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            else { return nil }
            return remoteConfig
        }()
    }
}

extension AdaptyPaywall.RemouteConfig: CustomStringConvertible {
    public var description: String {
        "(locale: \(locale)"
            + (jsonString.map { ", jsonString: \($0))" } ?? ")")
    }
}

extension AdaptyPaywall.RemouteConfig: Codable {
    enum CodingKeys: String, CodingKey {
        case adaptyLocale = "lang"
        case jsonString = "data"
    }
}
