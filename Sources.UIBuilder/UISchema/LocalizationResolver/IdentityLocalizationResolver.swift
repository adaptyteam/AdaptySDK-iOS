//
//  IdentityLocalizationResolver.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 18.11.2026.
//

import Foundation

struct IdentityLocalizationResolver: AdaptyUILocalizationResolver {
    func resolve(for locales: [String], from source: AdaptyUILocalizationSource) -> String? {
        return locales.first
    }
}
