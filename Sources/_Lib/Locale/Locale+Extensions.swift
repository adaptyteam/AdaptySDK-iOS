//
//  Locale+Extensions.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 01.02.2024
//
//

import StoreKit

extension Locale {
    @inlinable
    var unfCurrencyCode: String? {
        if #available(iOS 16, macOS 13, tvOS 16, watchOS 9, visionOS 1.0, *) {
            currency?.identifier
        } else {
            currencyCode
        }
    }

    @inlinable
    var unfRegionCode: String? {
        if #available(iOS 16, macOS 13, tvOS 16, watchOS 9, visionOS 1.0, *) {
            region?.identifier
        } else {
            regionCode
        }
    }

    @inlinable
    var unfLanguageCode: String? {
        if #available(iOS 16, macOS 13, tvOS 16, watchOS 9, visionOS 1.0, *) {
            language.languageCode?.identifier
        } else {
            languageCode
        }
    }
}
