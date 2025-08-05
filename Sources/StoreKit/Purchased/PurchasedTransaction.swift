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
    let environment: String?
    let payload: PurchasePayload?
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
        try container.encodeIfPresent(environment, forKey: .environment)

        try container.encodeIfPresent(payload?.paywallVariationId, forKey: .paywallVariationId)
        try container.encodeIfPresent(payload?.persistentPaywallVariationId, forKey: .persistentPaywallVariationId)
        try container.encodeIfPresent(payload?.persistentOnboardingVariationId, forKey: .persistentOnboardingVariationId)
    }
}

extension PurchasedTransaction {
    init(
        sk1Product: SK1Product?,
        sk1Transaction: SK1TransactionWithIdentifier,
        payload: PurchasePayload?
    ) {
        self.init(
            transactionId: sk1Transaction.unfIdentifier,
            originalTransactionId: sk1Transaction.unfOriginalIdentifier,
            vendorProductId: sk1Transaction.unfProductID,
            price: sk1Product?.price.decimalValue,
            priceLocale: sk1Product?.priceLocale.unfCurrencyCode,
            storeCountry: sk1Product?.priceLocale.unfRegionCode,
            subscriptionOffer: .init(sk1Transaction: sk1Transaction, sk1Product: sk1Product),
            environment: nil,
            payload: payload
        )
    }

    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
    init(
        sk2Product: SK2Product?,
        sk1Transaction: SK1TransactionWithIdentifier,
        payload: PurchasePayload?
    ) {
        self.init(
            transactionId: sk1Transaction.unfIdentifier,
            originalTransactionId: sk1Transaction.unfOriginalIdentifier,
            vendorProductId: sk1Transaction.unfProductID,
            price: sk2Product?.price,
            priceLocale: sk2Product?.priceFormatStyle.locale.unfCurrencyCode,
            storeCountry: sk2Product?.priceFormatStyle.locale.unfRegionCode,
            subscriptionOffer: .init(sk1Transaction: sk1Transaction, sk2Product: sk2Product),
            environment: nil,
            payload: payload
        )
    }

    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
    init(
        sk1Product: SK1Product?,
        sk2Transaction: SK2Transaction,
        payload: PurchasePayload?
    ) {
        self.init(
            transactionId: sk2Transaction.unfIdentifier,
            originalTransactionId: sk2Transaction.unfOriginalIdentifier,
            vendorProductId: sk2Transaction.unfProductID,
            price: sk1Product?.price.decimalValue,
            priceLocale: sk1Product?.priceLocale.unfCurrencyCode,
            storeCountry: sk1Product?.priceLocale.unfRegionCode,
            subscriptionOffer: .init(sk2Transaction: sk2Transaction, sk1Product: sk1Product),
            environment: sk2Transaction.unfEnvironment,
            payload: payload
        )
    }

    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
    init(
        sk2Product: SK2Product?,
        sk2Transaction: SK2Transaction,
        payload: PurchasePayload?
    ) {
        self.init(
            transactionId: sk2Transaction.unfIdentifier,
            originalTransactionId: sk2Transaction.unfOriginalIdentifier,
            vendorProductId: sk2Transaction.unfProductID,
            price: sk2Product?.price,
            priceLocale: sk2Product?.priceFormatStyle.locale.unfCurrencyCode,
            storeCountry: sk2Product?.priceFormatStyle.locale.unfRegionCode,
            subscriptionOffer: .init(sk2Transaction: sk2Transaction, sk2Product: sk2Product),
            environment: sk2Transaction.unfEnvironment,
            payload: payload
        )
    }
}
