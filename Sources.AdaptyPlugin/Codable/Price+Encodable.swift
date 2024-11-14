//
//  Price+Encodable.swift
//  AdaptyPlugin
//
//  Created by Aleksei Valiano on 12.11.2024.
//

import Adapty
import Foundation

struct Price: Encodable {
    let amount: Decimal
    let currencyCode: String?
    let currencySymbol: String?
    let localizedString: String?

    enum CodingKeys: String, CodingKey {
        case amount
        case currencyCode = "currency_code"
        case currencySymbol = "currency_symbol"
        case localizedString = "localized_string"
    }

    init(from product: some AdaptyProduct) {
        self.amount = product.price
        self.currencyCode = product.currencyCode
        self.currencySymbol = product.currencySymbol
        self.localizedString = product.localizedPrice
    }

    init(from offer: AdaptySubscriptionOffer) {
        self.amount = offer.price
        self.currencyCode = offer.currencyCode
        self.currencySymbol = nil
        self.localizedString = offer.localizedPrice
    }
}
