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
        if #available(macOS 13, iOS 16, tvOS 16, watchOS 9, *) {
            return self.currency?.identifier
        } else {
            return currencyCode
        }
    }
}
