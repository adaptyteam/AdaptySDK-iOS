//
//  Requests.CreateWebPaywallUrl.swift
//  AdaptyPlugin
//
//  Created by Aleksei Valiano on 05.05.2025.
//

import Adapty
import Foundation

extension Request {
    enum CreateWebPaywallUrl: AdaptyPluginRequest {
        static let method = "create_web_paywall_url"
        case product(AdaptyPluginPaywallProduct)
        case paywall(AdaptyPaywall)

        enum CodingKeys: CodingKey {
            case product
            case paywall
        }

        init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            if container.contains(.product) {
                self = try .product(container.decode(AdaptyPluginPaywallProduct.self, forKey: .product))
            } else {
                self = try .paywall(container.decode(AdaptyPaywall.self, forKey: .paywall))
            }
        }

        func execute() async throws -> AdaptyJsonData {
            switch self {
            case .product(let product):
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
                return try .success(await Adapty.createWebPaywallUrl(for: product).absoluteString)
            case .paywall(let paywall):
                return try .success(await Adapty.createWebPaywallUrl(for: paywall).absoluteString)
            }
        }
    }
}
