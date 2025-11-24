//
//  AdaptyPaywallProduct.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 20.10.2022.
//

import StoreKit

public protocol AdaptyPaywallProduct: AdaptyPaywallProductWithoutDeterminingOffer {
    var subscriptionOffer: AdaptySubscriptionOffer? { get }
}

public protocol AdaptyPaywallProductWithoutDeterminingOffer: AdaptyProduct {
    /// An internal Adapty Product Identifier
    var adaptyProductId: String { get }

    /// An access level id which was selected in Adapty Dashboard for this product, e.g. `premium`
    var accessLevelId: String { get }

    /// A product type which was selected in Adapty Dashboard for this product, e.g. `weekly`, `monthly`,  `annual`, etc.
    var adaptyProductType: String { get }

    var paywallProductIndex: Int { get }

    /// Same as `variationId` property of the parent AdaptyPaywall.
    var variationId: String { get }

    /// Same as `abTestName` property of the parent AdaptyPaywall.
    var paywallABTestName: String { get }

    /// Same as `name` property of the parent AdaptyPaywall.
    var paywallName: String { get }
}


