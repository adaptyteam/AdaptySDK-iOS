//
//  AdaptyUILocalizationResolver.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 18.11.2026.
//


public struct AdaptyUILocalizationSource {
    public let locales: [String]
    public let defaultLocale: String?
}

public protocol  AdaptyUILocalizationResolver {
    func resolve(for: [String], from: AdaptyUILocalizationSource) -> String?
}


extension AdaptyUILocalizationResolver {
    public func resolve(for locale: String, from source: AdaptyUILocalizationSource) -> String? {
        resolve(for: [locale], from: source)
    }

    func resolve(for locales: [LocaleId], from schema: AdaptyUISchema) -> LocaleId? {
        resolve(for: locales, from: .init(locales: schema.allLocalIds, defaultLocale: schema.defaultLocalId))
    }
}
