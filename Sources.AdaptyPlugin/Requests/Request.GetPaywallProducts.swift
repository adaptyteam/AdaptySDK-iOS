//
//  Request.GetPaywallProducts.swift
//  AdaptyPlugin
//
//  Created by Aleksei Valiano on 08.11.2024.
//

import Adapty
import Foundation

extension Request {
    struct GetPaywallProducts: AdaptyPluginRequest {
        static let method = "get_paywall_products"

        let paywall: AdaptyPaywall

        enum CodingKeys: CodingKey {
            case paywall
        }

        func execute() async throws -> AdaptyJsonData {
            let products = try await Adapty.getPaywallProducts(paywall: paywall)
            return .success(products.map(Response.AdaptyPluginPaywallProduct.init))
        }
    }
}
