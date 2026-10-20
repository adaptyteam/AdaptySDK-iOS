//
//  Price+Encodable.swift
//  AdaptyPlugin
//
//  Created by Aleksei Valiano on 12.11.2024.
//

import Adapty
import Foundation

struct Price: EncodableWithConfiguration {
    let amount: Decimal
    let localizedString: String

    enum CodingKeys: String, CodingKey {
        case amount
        case currencyCode = "currency_code"
        case currencySymbol = "currency_symbol"
        case localizedString = "localized_string"
    }

    func encode(to encoder: any Encoder, configuration: EncodingConfiguration ) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.amount, forKey: .amount)
        try container.encode(configuration.currencyCode, forKey: .currencyCode)
        try container.encodeIfPresent(configuration.currencySymbol, forKey: .currencySymbol)
        try container.encode(self.localizedString, forKey: .localizedString)
    }

    struct EncodingConfiguration {
        let currencyCode: String
        let currencySymbol: String?
    }

    init(from product: some AdaptyProduct) {
        self.amount = product.price
        self.localizedString = product.localizedPrice
    }

    init(from offer: AdaptySubscriptionOffer) {
        self.amount = offer.price
        self.localizedString = offer.localizedPrice
    }

    init(from terms: AdaptySubscriptionPricingTerms) {
        self.amount = terms.billingPrice
        self.localizedString = terms.localizedBillingPrice
    }

    init(from commitmentInfo: AdaptySubscriptionCommitmentInfo) {
        self.amount = commitmentInfo.price
        self.localizedString = commitmentInfo.localizedPrice
    }
}
