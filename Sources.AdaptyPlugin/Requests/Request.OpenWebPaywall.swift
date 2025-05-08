//
//  Request.OpenWebPaywall.swift
//  AdaptyPlugin
//
//  Created by Aleksei Valiano on 03.05.2025.
//

import Adapty
import Foundation

extension Request {
    enum OpenWebPaywall: AdaptyPluginRequest {
        static let method = "open_web_paywall"
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
                try await Adapty.openWebPaywall(for: product)
            case .paywall(let paywall):
                try await Adapty.openWebPaywall(for: paywall)
            }
            return .success()
        }
    }
}
