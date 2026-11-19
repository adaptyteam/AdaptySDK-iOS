//
//  SystemLocalizationResolver.swift
//  AdaptyUIBulder
//
//  Created by Aleksei Valiano on 18.11.2026.
//

import Foundation

struct SystemLocalizationResolver {
    func resolve(for locales: [String], from source: AdaptyUILocalizationSource) -> String? {
        let noMatch = "zxx"
        guard !locales.isEmpty,
              let found = Bundle.preferredLocalizations(from: [noMatch] + source.locales, forPreferences: locales).first,
              found != noMatch
        else { return source.defaultLocale }
        return found
    }
}
