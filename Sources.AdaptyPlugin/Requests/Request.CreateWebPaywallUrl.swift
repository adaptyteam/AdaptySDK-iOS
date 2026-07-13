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
        let paywall: AdaptyFlowPaywall?
        let product: AdaptyPluginPaywallProduct?

        enum CodingKeys: CodingKey {
            case paywall
            case product
        }

        init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            paywall = try container.decodeIfPresent(AdaptyFlowPaywall.self, forKey: .paywall)
            product = try container.decodeIfPresent(AdaptyPluginPaywallProduct.self, forKey: .product)
        }

        func execute() async throws -> AdaptyJsonData {
            let url: URL
            if let paywall {
                url = try await Adapty.createWebPaywallUrl(for: paywall)
            } else if let pluginProduct = product {
                let product = try await Adapty.getPaywallProduct(
                    flowProductId: pluginProduct.flowProductId,
                    adaptyProductId: pluginProduct.adaptyProductId,
                    productInfo: pluginProduct.productInfo,
                    paywallProductIndex: pluginProduct.paywallProductIndex,
                    subscriptionOfferIdentifier: pluginProduct.subscriptionOfferIdentifier,
                    variationId: pluginProduct.variationId,
                    paywallABTestName: pluginProduct.paywallABTestName,
                    paywallName: pluginProduct.paywallName,
                    webPaywallBaseUrl: pluginProduct.webPaywallBaseUrl
                )
                url = try await Adapty.createWebPaywallUrl(for: product)
            } else {
                throw AdaptyPluginError.wrongParam("create_web_paywall_url requires either 'paywall' or 'product'")
            }
            return .success(url.absoluteString)
        }
    }
}
