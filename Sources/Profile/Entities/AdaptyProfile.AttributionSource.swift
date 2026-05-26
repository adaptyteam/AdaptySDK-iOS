//
//  AdaptyProfile.AttributionSource.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 26.05.2026.
//

extension AdaptyProfile {
    public struct AttributionSource: RawRepresentable, Hashable, Sendable, Codable {
        public let rawValue: String

        public init(rawValue: String) {
            self.rawValue = rawValue
        }

        public static let appleSearchAds = AttributionSource(rawValue: "apple_search_ads")
    }
}

