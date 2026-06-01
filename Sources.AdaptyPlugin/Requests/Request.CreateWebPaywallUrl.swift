//
//  Request.CreateWebPaywallUrl.swift
//  AdaptyPlugin
//
//  Created by Aleksei Valiano on 05.05.2025.
//

import Adapty
import Foundation

extension Request {
    struct CreateWebPaywallUrl: AdaptyPluginRequest {
        static let method = "create_web_paywall_url"
        let product: AdaptyPluginPaywallProduct

        enum CodingKeys: CodingKey {
            case product
        }

        init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            product = try container.decode(AdaptyPluginPaywallProduct.self, forKey: .product)
        }

        func execute() async throws -> AdaptyJsonData {
            let product = try await Adapty.getPaywallProduct(
                flowProductId: product.flowProductId,
                adaptyProductId: product.adaptyProductId,
                productInfo: product.productInfo,
                paywallProductIndex: product.paywallProductIndex,
                subscriptionOfferIdentifier: product.subscriptionOfferIdentifier,
                variationId: product.variationId,
                paywallABTestName: product.paywallABTestName,
                paywallName: product.paywallName,
                webPaywallBaseUrl: product.webPaywallBaseUrl
            )
            return try await .success(Adapty.createWebPaywallUrl(for: product).absoluteString)
        }
    }
}

