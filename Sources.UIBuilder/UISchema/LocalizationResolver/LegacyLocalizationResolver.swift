//
//  LegacyLocalizationResolver.swift
//  AdaptyUIBulder
//
//  Created by Aleksei Valiano on 11.11.2026.
//

import Foundation

struct LegacyLocalizationResolver: AdaptyUILocalizationResolver {
    let ignoresCase: Bool
    let replaceUnderscores: Bool

    init(ignoresCase: Bool = false, replaceUnderscores: Bool = false) {
        self.ignoresCase = ignoresCase
        self.replaceUnderscores = replaceUnderscores
    }

    func resolve(for locales: [String], from source: AdaptyUILocalizationSource) -> String? {
        guard let locale = locales.first else { return source.defaultLocale }
        return resolve(for: locale, from: source)
    }

    func resolve(for locale: String, from source: AdaptyUILocalizationSource) -> String? {
        var parts = locale.replacingOccurrences(of: "_", with: "-")
            .lowercased()
            .split(separator: "-", omittingEmptySubsequences: false)

        let locales = Dictionary(
            source.locales.map { original in
                var key = replaceUnderscores
                    ? original.replacingOccurrences(of: "_", with: "-")
                    : original
                if ignoresCase { key = key.lowercased() }
                return (key, original)
            },
            uniquingKeysWith: { first, _ in first }
        )

        while !parts.isEmpty {
            let candidate = parts.joined(separator: "-")
            if let found = locales[candidate] {
                guard candidate.isEmpty else { return found }
                return source.defaultLocale
            }
            parts.removeLast()
        }
        return source.defaultLocale
    }
}
