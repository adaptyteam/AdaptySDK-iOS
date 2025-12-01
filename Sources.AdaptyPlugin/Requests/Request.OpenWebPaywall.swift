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
        let operation: Operation
        let presentation: AdaptyWebPresentation
        
        enum CodingKeys: String, CodingKey {
            case presentation = "open_in"
        }
        
        init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            presentation = try container.decodeIfPresent(AdaptyWebPresentation.self, forKey: .presentation) ?? .externalBrowser
            operation = try Operation(from: decoder)
        }
        
        func execute() async throws -> AdaptyJsonData {
            switch operation {
            case .openProduct(let product):
                let product = try await Adapty.getPaywallProduct(
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
            case .openPaywall(let paywall):
                try await Adapty.openWebPaywall(for: paywall, in: presentation)
            }
            return .success()
        }
        
        enum Operation {
            case openProduct(AdaptyPluginPaywallProduct)
            case openPaywall(AdaptyPaywall)
            
            enum CodingKeys: CodingKey {
                case product
                case paywall
            }
            
            init(from decoder: any Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                if container.contains(.product) {
                    self = try .openProduct(container.decode(AdaptyPluginPaywallProduct.self, forKey: .product))
                } else {
                    self = try .openPaywall(container.decode(AdaptyPaywall.self, forKey: .paywall))
                }
            }
        }
    }
}
