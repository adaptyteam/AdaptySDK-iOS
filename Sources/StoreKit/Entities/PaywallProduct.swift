//
//  PaywallProduct.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 20.10.2022.
//

import StoreKit

struct PaywallProduct: AdaptyProduct, AdaptyPaywallProduct, WebPaywallURLProviding {
    let skProduct: StoreKit.Product

    let adaptyProductId: String

    let productInfo: BackendProductInfo

    var accessLevelId: String { productInfo.accessLevelId }
    var adaptyProductType: String { productInfo.period.rawValue }

    let paywallProductIndex: Int

    let subscriptionOffer: AdaptySubscriptionOffer?

    /// Same as `variationId` property of the parent AdaptyPaywall.
    let variationId: String

    /// Same as `abTestName` property of the parent AdaptyPaywall.
    let paywallABTestName: String

    /// Same as `name` property of the parent AdaptyPaywall.
    let paywallName: String

    let webPaywallBaseUrl: URL?

    var description: String {
        "(adaptyProductId: \(adaptyProductId), info: \(productInfo), paywallName: \(paywallName), variationId: \(variationId), paywallABTestName: \(paywallABTestName), subscriptionOffer:\(subscriptionOffer.map(\.description) ?? "nil") , skProduct:\(skProduct)"
    }
}

struct PaywallProductWithoutDeterminingOffer: AdaptyProduct, AdaptyPaywallProductWithoutDeterminingOffer, WebPaywallURLProviding {
    let skProduct: StoreKit.Product

    let adaptyProductId: String

    let productInfo: BackendProductInfo
    var accessLevelId: String { productInfo.accessLevelId }
    var adaptyProductType: String { productInfo.period.rawValue }

    let paywallProductIndex: Int

    /// Same as `variationId` property of the parent AdaptyPaywall.
    let variationId: String

    /// Same as `abTestName` property of the parent AdaptyPaywall.
    let paywallABTestName: String

    /// Same as `name` property of the parent AdaptyPaywall.
    let paywallName: String

    let webPaywallBaseUrl: URL?

    var description: String {
        "(adaptyProductId: \(adaptyProductId), info: \(productInfo), paywallName: \(paywallName), variationId: \(variationId), paywallABTestName: \(paywallABTestName), skProduct:\(skProduct)"
    }
}
