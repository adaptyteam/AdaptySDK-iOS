//
//  AdaptyPaywallProduct.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 20.10.2022.
//

import StoreKit

public protocol AdaptyPaywallProductWithoutDeterminingOffer: AdaptyProduct {
    var adaptyProductId: String { get }

    var paywallProductIndex: Int { get }

    /// Same as `variationId` property of the parent AdaptyPaywall.
    var variationId: String { get }

    /// Same as `abTestName` property of the parent AdaptyPaywall.
    var paywallABTestName: String { get }

    /// Same as `name` property of the parent AdaptyPaywall.
    var paywallName: String { get }
}

public protocol AdaptyPaywallProduct: AdaptyPaywallProductWithoutDeterminingOffer {
    var subscriptionOffer: AdaptySubscriptionOffer? { get }
}
