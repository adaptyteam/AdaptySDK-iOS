//
//  Request.MakePurchase.swift
//  AdaptyPlugin
//
//  Created by Aleksei Valiano on 08.11.2024.
//

import Adapty
import Foundation

extension Request {
    struct MakePurchase: AdaptyPluginRequest {
        static let method = "make_purchase"
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
                webPaywallBaseUrl: product.webPaywallBaseUrl
            )
            let result = try await Adapty.makePurchase(product: product)
            return .success(result)
        }
    }
}
