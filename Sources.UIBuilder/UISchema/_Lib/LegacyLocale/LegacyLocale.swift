//
//  LegacyLocale.swift
//  AdaptyUIBulder
//
//  Created by Aleksei Valiano on 11.11.2026.
//

import Foundation

enum LegacyLocale {
    static func select(for locale: LocaleId, from schema: AdaptyUISchema) -> LocaleId? {
        select(for: locale, from: schema.allLocalIds, default: schema.defaultLocalId)
    }

    static func select(for locale: LocaleId, from locales: [LocaleId], default defaultLocale: LocaleId?) -> LocaleId? {
        var parts = locale.replacingOccurrences(of: "_", with: "-")
            .lowercased()
            .split(separator: "-", omittingEmptySubsequences: false)
        let locales = Set(locales.map{ $0 })

        while !parts.isEmpty {
            let candidate = parts.joined(separator: "-")
            if locales.contains(candidate) {
                return candidate.isEmpty ? defaultLocale : candidate
            }
            parts.removeLast()
        }

        return defaultLocale
    }
}
