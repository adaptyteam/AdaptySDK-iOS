//
//  Request.OpenWebPaywall.swift
//  AdaptyPlugin
//
//  Created by Aleksei Valiano on 03.05.2025.
//

import Adapty
import Foundation

extension Request {
    struct OpenWebPaywall: AdaptyPluginRequest {
        static let method = "open_web_paywall"
        let product: AdaptyPluginPaywallProduct
        let presentation: AdaptyWebPresentation

        enum CodingKeys: String, CodingKey {
            case product
            case presentation = "open_in"
        }

        init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            product = try container.decode(AdaptyPluginPaywallProduct.self, forKey: .product)
            presentation = try container.decodeIfPresent(AdaptyWebPresentation.self, forKey: .presentation) ?? .externalBrowser
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
            try await Adapty.openWebPaywall(for: product, in: presentation)
            return .success()
        }
    }
}

