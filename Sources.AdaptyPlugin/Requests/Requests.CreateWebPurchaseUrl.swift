//
//  Requests.CreateWebPurchaseUrl.swift
//  AdaptyPlugin
//
//  Created by Aleksei Valiano on 05.05.2025.
//

import Adapty
import Foundation

extension Request {
    struct CreateWebPurchaseUrl: AdaptyPluginRequest {
        static let method = "create_web_purchase_url"
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
            let result = try await Adapty.createWebPurchaseUrl(product: product)
            return .success(result)
        }
    }
}
