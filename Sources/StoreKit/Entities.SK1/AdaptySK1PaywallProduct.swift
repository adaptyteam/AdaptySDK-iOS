//
//  AdaptySK1PaywallProduct.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 20.10.2022.
//

import StoreKit

struct AdaptySK1PaywallProduct: AdaptySK1Product, AdaptyPaywallProduct, WebPaywallURLProviding {
    let skProduct: SK1Product
    let backendProduct: BackendProduct

    public var adaptyProductId: String { backendProduct.adaptyId }
    public var accessLevelId: String { backendProduct.accessLevelId }
    public var adaptyProductType: String { backendProduct.period.rawValue }

    public let paywallProductIndex: Int

    public let subscriptionOffer: AdaptySubscriptionOffer?

    /// Same as `variationId` property of the parent AdaptyPaywall.
    public let variationId: String

    /// Same as `abTestName` property of the parent AdaptyPaywall.
    public let paywallABTestName: String

    /// Same as `name` property of the parent AdaptyPaywall.
    public let paywallName: String

    let webPaywallBaseUrl: URL?

    public var description: String {
        "(product: \(backendProduct), paywallName: \(paywallName), variationId: \(variationId), paywallABTestName: \(paywallABTestName), subscriptionOffer:\(subscriptionOffer.map { $0.description } ?? "nil") , skProduct:\(skProduct)"
    }
}

struct AdaptySK1PaywallProductWithoutDeterminingOffer: AdaptySK1Product, AdaptyPaywallProductWithoutDeterminingOffer, WebPaywallURLProviding {
    let skProduct: SK1Product
    let backendProduct: BackendProduct

    public var adaptyProductId: String { backendProduct.adaptyId }
    public var accessLevelId: String { backendProduct.accessLevelId }
    public var adaptyProductType: String { backendProduct.period.rawValue }

    public let paywallProductIndex: Int

    /// Same as `variationId` property of the parent AdaptyPaywall.
    public let variationId: String

    /// Same as `abTestName` property of the parent AdaptyPaywall.
    public let paywallABTestName: String

    /// Same as `name` property of the parent AdaptyPaywall.
    public let paywallName: String

    let webPaywallBaseUrl: URL?

    public var description: String {
        "(product: \(backendProduct), paywallName: \(paywallName), variationId: \(variationId), paywallABTestName: \(paywallABTestName), skProduct:\(skProduct)"
    }
}
