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
        let paywall: AdaptyFlowPaywall?
        let product: AdaptyPluginPaywallProduct?
        let presentation: AdaptyWebPresentation

        enum CodingKeys: String, CodingKey {
            case paywall
            case product
            case presentation = "open_in"
        }

        init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            paywall = try container.decodeIfPresent(AdaptyFlowPaywall.self, forKey: .paywall)
            product = try container.decodeIfPresent(AdaptyPluginPaywallProduct.self, forKey: .product)
            presentation = try container.decodeIfPresent(AdaptyWebPresentation.self, forKey: .presentation) ?? .externalBrowser
        }

        func execute() async throws -> AdaptyJsonData {
            if let paywall {
                try await Adapty.openWebPaywall(for: paywall, in: presentation)
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
                try await Adapty.openWebPaywall(for: product, in: presentation)
            } else {
                throw AdaptyPluginError.wrongParam("open_web_paywall requires either 'paywall' or 'product'")
            }
            return .success()
        }
    }
}
