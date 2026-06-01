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

        let flow: AdaptyFlow

        enum CodingKeys: CodingKey {
            case flow
        }

        func execute() async throws -> AdaptyJsonData {
            let products = try await Adapty.getPaywallProducts(flow: flow)
            return .success(products.map(Response.AdaptyPluginPaywallProduct.init))
        }
    }
}
