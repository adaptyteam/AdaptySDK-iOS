//
//  PurchasedTransaction.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 08.09.2022.
//

import Foundation

struct PurchasedTransaction: Sendable {
    let transactionId: String
    let originalTransactionId: String
    let vendorProductId: String
    let price: Decimal?
    let priceLocale: String?
    let storeCountry: String?
    let subscriptionOffer: SubscriptionOffer?
    let environment: String
    let payload: PurchasePayload?

    init(
        product: AdaptyProduct?,
        transaction: SKTransaction,
        payload: PurchasePayload?
    ) {
        self.transactionId = transaction.unfIdentifier
        self.originalTransactionId = transaction.unfOriginalIdentifier
        self.vendorProductId = transaction.unfProductID
        self.price = product?.price
        self.priceLocale = product?.priceLocale.unfCurrencyCode
        self.storeCountry = product?.priceLocale.unfRegionCode
        self.subscriptionOffer = .init(transaction: transaction, product: product)
        self.environment = transaction.unfEnvironment
        self.payload = payload
    }
}

extension PurchasedTransaction: Encodable {
    enum CodingKeys: String, CodingKey {
        case transactionId = "transaction_id"
        case originalTransactionId = "original_transaction_id"
        case vendorProductId = "vendor_product_id"
        case paywallVariationId = "variation_id"
        case persistentPaywallVariationId = "variation_id_persistent"
        case persistentOnboardingVariationId = "onboarding_variation_id"
        case originalPrice = "original_price"
        case discountPrice = "discount_price"
        case priceLocale = "price_locale"
        case storeCountry = "store_country"
        case promotionalOfferId = "promotional_offer_id"
        case subscriptionOffer = "offer"
        case environment
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(transactionId, forKey: .transactionId)
        try container.encode(originalTransactionId, forKey: .originalTransactionId)
        try container.encode(vendorProductId, forKey: .vendorProductId)
        try container.encodeIfPresent(price, forKey: .originalPrice)
        try container.encodeIfPresent(subscriptionOffer?.price, forKey: .discountPrice)
        try container.encodeIfPresent(priceLocale, forKey: .priceLocale)
        try container.encodeIfPresent(storeCountry, forKey: .storeCountry)
        try container.encodeIfPresent(subscriptionOffer?.id, forKey: .promotionalOfferId)
        try container.encodeIfPresent(subscriptionOffer, forKey: .subscriptionOffer)
        try container.encode(environment, forKey: .environment)

        try container.encodeIfPresent(payload?.paywallVariationId, forKey: .paywallVariationId)
        try container.encodeIfPresent(payload?.persistentPaywallVariationId, forKey: .persistentPaywallVariationId)
        try container.encodeIfPresent(payload?.persistentOnboardingVariationId, forKey: .persistentOnboardingVariationId)
    }
}
