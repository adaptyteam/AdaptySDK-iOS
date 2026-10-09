//
//  AdaptyPromotedProduct.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 30.06.2026.
//

import StoreKit

public struct AdaptyPromotedProduct: AdaptyProduct {
    public let purchaseIntentId: String
    public let skProduct: StoreKit.Product
    public let subscriptionPricingTerms: AdaptySubscriptionPricingTerms?
    public let subscriptionOffer: AdaptySubscriptionOffer?
    let skOffer: StoreKit.Product.SubscriptionOffer?

    @inlinable
    public var description: String {
        "(skProduct:\(skProduct), subscriptionOffer:\(subscriptionOffer.map(\.description), default: "nil"))"
    }
}
