//
//  AdaptyPrice.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 25.07.2023
//

import Foundation

struct AdaptyPrice {
    let value: NSDecimalNumber
    let locale: Locale

    var amount: Decimal { value.decimalValue }
    var currencyCode: String? { locale.ext.currencyCode }
    var currencySymbol: String? { locale.currencySymbol }
    var localizedString: String? { locale.ext.localized(price: value) }
}

extension AdaptyPrice: Equatable, Sendable {}

extension AdaptyPrice: Encodable {
    enum CodingKeys: String, CodingKey {
        case amount
        case currencyCode = "currency_code"
        case currencySymbol = "currency_symbol"
        case localizedString = "localized_string"
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(amount, forKey: .amount)
        try container.encodeIfPresent(currencyCode, forKey: .currencyCode)
        try container.encodeIfPresent(currencySymbol, forKey: .currencySymbol)
        try container.encodeIfPresent(localizedString, forKey: .localizedString)
    }
}
