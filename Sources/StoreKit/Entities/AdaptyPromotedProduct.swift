//
//  AdaptyPromotedProduct.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 30.06.2026.
//

import StoreKit

public struct AdaptyPromotedProduct: AdaptyProduct {
    public let skProduct: StoreKit.Product
    public let subscriptionOffer: AdaptySubscriptionOffer?

    @inlinable
    public var description: String {
        "(skProduct:\(skProduct), subscriptionOffer:\(subscriptionOffer.map(\.description) ?? "nil"))"
    }
}
