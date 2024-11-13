//
//  Price+Encodable.swift
//  AdaptyPlugin
//
//  Created by Aleksei Valiano on 12.11.2024.
//

import Adapty
import Foundation

extension Price: Encodable {
    enum CodingKeys: String, CodingKey {
        case amount
        case currencyCode = "currency_code"
        case currencySymbol = "currency_symbol"
        case localizedString = "localized_string"
    }

    package func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(amount, forKey: .amount)
        try container.encodeIfPresent(currencyCode, forKey: .currencyCode)
        try container.encodeIfPresent(currencySymbol, forKey: .currencySymbol)
        try container.encodeIfPresent(localizedString, forKey: .localizedString)
    }
}
