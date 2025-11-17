//
//  SK2Product.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 01.02.2024
//

import StoreKit

typealias SK2Product = Product

extension SK2Product {
    @inlinable
    var unfCurrencyCode: String? {
        if #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *) {
            return priceFormatStyle.currencyCode
        }

        guard let decoded = try? JSONSerialization.jsonObject(with: jsonRepresentation),
              let dict = decoded as? [String: Any],
              let attributes = dict["attributes"] as? [String: Any],
              let offers = attributes["offers"] as? [[String: Any]],
              let code = offers.first?["currencyCode"] as? String
        else {
            return nil
        }

        return code
    }

    @inlinable
    var unfPriceLocale: Locale { priceFormatStyle.locale }

    @inlinable
    var unfPeriodLocale: Locale {
        if #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *) {
            return subscriptionPeriodFormatStyle.locale
        }
        return .autoupdatingCurrent
    }
}
