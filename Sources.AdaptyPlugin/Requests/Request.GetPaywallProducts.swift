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
        static let method = Method.getPaywallProducts

        let paywall: AdaptyPaywall

        enum CodingKeys: CodingKey {
            case paywall
        }

        init(from jsonDictionary: AdaptyJsonDictionary) throws {
            try self.init(
                paywall: jsonDictionary.value(forKey: CodingKeys.paywall)
            )
        }

        init(paywall: KeyValue) throws {
            self.paywall = try paywall.decode(AdaptyPaywall.self)
        }

        func execute() async throws -> AdaptyJsonData {
            let products = try await Adapty.getPaywallProducts(paywall: paywall)
            return .success(products.map(Response.AdaptyPluginPaywallProduct.init))
        }
    }
}

public extension AdaptyPlugin {
    @objc static func getPaywallProducts(
        paywall: String,
        _ completion: @escaping AdaptyJsonDataCompletion
    ) {
        typealias CodingKeys = Request.GetPaywallProducts.CodingKeys
        execute(with: completion) { try Request.GetPaywallProducts(
            paywall: .init(key: CodingKeys.paywall, value: paywall)

        ) }
    }
}
