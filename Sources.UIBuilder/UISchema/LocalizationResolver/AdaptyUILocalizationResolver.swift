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
    func resolve(for locale: String, from source: AdaptyUILocalizationSource) -> String?
}


extension AdaptyUILocalizationResolver {
    func resolve(for locale: LocaleId, from schema: AdaptyUISchema) -> LocaleId? {
        resolve(for: locale, from: .init(locales: schema.allLocalIds, defaultLocale: schema.defaultLocalId))
    }
}
