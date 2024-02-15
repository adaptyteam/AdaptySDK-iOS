//
//  Locale+Extensions.swift
//
//
//  Created by Aleksei Valiano on 01.02.2024
//
//

import Foundation

internal extension Locale {
    var a_currencyCode: String? {
        guard #available(macOS 13, iOS 16, tvOS 16, watchOS 9, *) else {
            return currencyCode
        }
        return currency?.identifier
    }

    var a_regionCode: String? {
        guard #available(macOS 13, iOS 16, tvOS 16, watchOS 9, *) else {
            return regionCode
        }
        return region?.identifier
    }
}
