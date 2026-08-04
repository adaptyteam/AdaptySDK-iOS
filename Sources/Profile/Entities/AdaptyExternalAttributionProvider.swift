//
//  AdaptyExternalAttributionProvider.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 26.05.2026.
//

import Foundation

/// An external attribution provider recognized by the Adapty backend.
///
/// The predefined values are a snapshot of the providers available when this
/// SDK version was released. If the backend adds another provider, pass its
/// identifier with ``init(rawValue:)`` without waiting for an SDK update.
public struct AdaptyExternalAttributionProvider: RawRepresentable, Hashable, Sendable, Codable {
    public let rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue.trimmed
    }

    public static let appleAds = AdaptyExternalAttributionProvider(rawValue: "apple_search_ads")
    public static let adjust = AdaptyExternalAttributionProvider(rawValue: "adjust")
    public static let appsflyer = AdaptyExternalAttributionProvider(rawValue: "appsflyer")
    public static let branch = AdaptyExternalAttributionProvider(rawValue: "branch")
    public static let tenjin = AdaptyExternalAttributionProvider(rawValue: "tenjin")
    public static let custom = AdaptyExternalAttributionProvider(rawValue: "custom")
}

extension AdaptyExternalAttributionProvider: CustomStringConvertible {
    public var description: String {
        String(describing: rawValue)
    }
}

extension AdaptyExternalAttributionProvider: ExpressibleByStringLiteral {
    public init(stringLiteral: String) {
        self.init(rawValue: stringLiteral)
    }
}
