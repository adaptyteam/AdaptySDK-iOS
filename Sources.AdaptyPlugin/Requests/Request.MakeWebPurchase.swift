//
//  Request.MakeWebPurchase.swift
//  AdaptyPlugin
//
//  Created by Aleksei Valiano on 03.05.2025.
//

import Adapty
import Foundation

extension Request {
    struct MakeWebPurchase: AdaptyPluginRequest {
        static let method = "make_web_purchase"
        let product: AdaptyPluginPaywallProduct

        enum CodingKeys: CodingKey {
            case product
        }

        func execute() async throws -> AdaptyJsonData {
            let product = try await Adapty.getPaywallProduct(
                vendorProductId: product.vendorProductId,
                adaptyProductId: product.adaptyProductId,
                paywallProductIndex: product.paywallProductIndex,
                subscriptionOfferIdentifier: product.subscriptionOfferIdentifier,
                variationId: product.variationId,
                paywallABTestName: product.paywallABTestName,
                paywallName: product.paywallName,
                paywallPurchaseUrl: product.paywallPurchaseURL
            )
            let result = try await Adapty.makeWebPurchase(product: product)
            return .success(result)
        }
    }
}
