//
//  AdaptyUILocalizationResolver.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 18.11.2026.
//

public struct AdaptyUILocalizationSource: Sendable {
    public let locales: [String]
    public let defaultLocale: String?
}

public protocol AdaptyUILocalizationResolver: Sendable {
    func resolve(for: [String], from: AdaptyUILocalizationSource) async -> String?
}

public enum AdaptyUILocalizationStrategy: Sendable {
    case `default`
    case legacy
    case system
    case identity
    case custom(AdaptyUILocalizationResolver)
}
