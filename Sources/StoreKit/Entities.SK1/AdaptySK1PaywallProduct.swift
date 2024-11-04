//
//  AdaptySK1PaywallProduct.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 20.10.2022.
//

import StoreKit

public struct AdaptySK1PaywallProduct: AdaptySK1Product {
    let skProduct: SK1Product

    public let adaptyProductId: String

    public let subscriptionOffer: AdaptySubscriptionOffer?

    /// Same as `variationId` property of the parent AdaptyPaywall.
    public let variationId: String

    /// Same as `abTestName` property of the parent AdaptyPaywall.
    public let paywallABTestName: String

    /// Same as `name` property of the parent AdaptyPaywall.
    public let paywallName: String
    
    public var description: String {
        "(vendorProductId: \(vendorProductId), paywallName: \(paywallName), adaptyProductId: \(adaptyProductId), variationId: \(variationId), paywallABTestName: \(paywallABTestName), subscriptionOffer:\(subscriptionOffer.map({ $0.description }) ?? "nil") , skProduct:\(skProduct)"
    }
}


extension AdaptySK1PaywallProduct: AdaptyPaywallProduct {}

public struct AdaptySK1PaywallProductWithoutDeterminingOffer: AdaptySK1Product {
    let skProduct: SK1Product

    public let adaptyProductId: String

    /// Same as `variationId` property of the parent AdaptyPaywall.
    public let variationId: String

    /// Same as `abTestName` property of the parent AdaptyPaywall.
    public let paywallABTestName: String

    /// Same as `name` property of the parent AdaptyPaywall.
    public let paywallName: String
    
    public var description: String {
        "(vendorProductId: \(vendorProductId), paywallName: \(paywallName), adaptyProductId: \(adaptyProductId), variationId: \(variationId), paywallABTestName: \(paywallABTestName), skProduct:\(skProduct)"
    }
}

extension AdaptySK1PaywallProductWithoutDeterminingOffer: AdaptyPaywallProductWithoutDeterminingOffer {}
