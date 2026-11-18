//
//  SystemLocalizationResolver.swift
//  AdaptyUIBulder
//
//  Created by Aleksei Valiano on 18.11.2026.
//

import Foundation

struct SystemLocalizationResolver: AdaptyUILocalizationResolver {
    func resolve(for locale: String, from source: AdaptyUILocalizationSource) -> String? {
        let noMatch = "zxx"
        guard let found = Bundle.preferredLocalizations(from: [noMatch] + source.locales, forPreferences: [locale]).first,
              found != noMatch
        else { return source.defaultLocale }
        return found
    }
}
