//
//  AdaptySK1PaywallProduct.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 20.10.2022.
//

import StoreKit

public struct AdaptySK1PaywallProduct: AdaptySK1Product {
    package let adaptyProductId: String

    let skProduct: SK1Product

    public let subscriptionOffer: AdaptySubscriptionOffer.Available

    /// Same as `variationId` property of the parent AdaptyPaywall.
    public let variationId: String

    /// Same as `abTestName` property of the parent AdaptyPaywall.
    public let paywallABTestName: String

    /// Same as `name` property of the parent AdaptyPaywall.
    public let paywallName: String

    init(
        sk1Product: SK1Product,
        adaptyProductId: String,
        subscriptionOffer: AdaptySubscriptionOffer.Available,
        variationId: String,
        paywallABTestName: String,
        paywallName: String
    ) {
        self.skProduct = sk1Product
        self.adaptyProductId = adaptyProductId
        self.subscriptionOffer = subscriptionOffer
        self.variationId = variationId
        self.paywallABTestName = paywallABTestName
        self.paywallName = paywallName
    }
    
    public var description: String {
        "(vendorProductId: \(vendorProductId), paywallName: \(paywallName), adaptyProductId: \(adaptyProductId), variationId: \(variationId), paywallABTestName: \(paywallABTestName), subscriptionOffer:\(subscriptionOffer) , skProduct:\(skProduct)"
    }
}


extension AdaptySK1PaywallProduct: AdaptyPaywallProduct {}
extension AdaptySK1PaywallProduct: PaywallProduct {}
