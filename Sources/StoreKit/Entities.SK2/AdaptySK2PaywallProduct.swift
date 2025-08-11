//
//  AdaptySK2PaywallProduct.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 20.10.2022.
//

import StoreKit

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
struct AdaptySK2PaywallProduct: AdaptySK2Product, AdaptyPaywallProduct, WebPaywallURLProviding {
    let skProduct: SK2Product
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

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
struct AdaptySK2PaywallProductWithoutDeterminingOffer: AdaptySK2Product, AdaptyPaywallProductWithoutDeterminingOffer, WebPaywallURLProviding {
    let skProduct: SK2Product
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
