//
//  AdaptyPaywallProduct.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 20.10.2022.
//

import StoreKit

public struct AdaptyPaywallProduct: AdaptyProduct, WebPaywallURLProviding {
    public let skProduct: StoreKit.Product

    package let flowProductId: String?

    public let adaptyProductId: String

    let productInfo: BackendProductInfo

    public var accessLevelId: String {
        productInfo.accessLevelId
    }

    public var adaptyProductType: String {
        productInfo.period.rawValue
    }

    public let paywallProductIndex: Int

    public let subscriptionOffer: AdaptySubscriptionOffer?

    /// Same as `variationId` property of the parent AdaptyFlowPaywall.
    public let variationId: String

    /// Same as `abTestName` property of the parent AdaptyFlowPaywall.
    public let paywallABTestName: String

    /// Same as `name` property of the parent AdaptyFlowPaywall.
    public let paywallName: String

    package let webPaywallBaseUrl: URL?

    public var description: String {
        "(adaptyProductId: \(adaptyProductId), info: \(productInfo), paywallName: \(paywallName), variationId: \(variationId), paywallABTestName: \(paywallABTestName), subscriptionOffer:\(subscriptionOffer.map(\.description) ?? "nil") , skProduct:\(skProduct)"
    }
}
