//
//  AdaptySK2PaywallProduct.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 20.10.2022.
//

import StoreKit

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
public struct AdaptySK2PaywallProduct: AdaptySK2Product {
    package let adaptyProductId: String

    let skProduct: SK2Product

    public let subscriptionOffer: AdaptySubscriptionOffer.Available

    /// Same as `variationId` property of the parent AdaptyPaywall.
    public let variationId: String

    /// Same as `abTestName` property of the parent AdaptyPaywall.
    public let paywallABTestName: String

    /// Same as `name` property of the parent AdaptyPaywall.
    public let paywallName: String

    init(
        sk2Product: SK2Product,
        adaptyProductId: String,
        subscriptionOffer: AdaptySubscriptionOffer.Available,
        variationId: String,
        paywallABTestName: String,
        paywallName: String
    ) {
        self.skProduct = sk2Product
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

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
extension AdaptySK2PaywallProduct: AdaptyPaywallProduct {}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
extension AdaptySK2PaywallProduct: PaywallProduct {}
