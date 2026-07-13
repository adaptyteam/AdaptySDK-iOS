//
//  AdaptyAttributionSource.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 26.05.2026.
//

import Foundation

public struct AdaptyAttributionSource: RawRepresentable, Hashable, Sendable, Codable {
    public let rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue.trimmed
    }

    public static let appleAds = AdaptyAttributionSource(rawValue: "apple_search_ads")
    public static let adjust = AdaptyAttributionSource(rawValue: "adjust")
    public static let appsflyer = AdaptyAttributionSource(rawValue: "appsflyer")
    public static let branch = AdaptyAttributionSource(rawValue: "branch")
    public static let tenjin = AdaptyAttributionSource(rawValue: "tenjin")
}

extension AdaptyAttributionSource: CustomStringConvertible {
    public var description: String {
        String(describing: rawValue)
    }
}

extension AdaptyAttributionSource: ExpressibleByStringLiteral {
    public init(stringLiteral: String) {
        self.init(rawValue: stringLiteral)
    }
}

