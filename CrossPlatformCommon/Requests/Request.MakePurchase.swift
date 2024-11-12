//
//  Request.MakePurchase.swift
//  AdaptyPlugin
//
//  Created by Aleksei Valiano on 08.11.2024.
//

import Adapty
import Foundation

extension Request {
    struct MakePurchase: AdaptyPluginRequest {
        static let method = Method.makePurchase
        let product: AdaptyPluginPaywallProduct

        enum CodingKeys: CodingKey {
            case product
        }

        init(from jsonDictionary: AdaptyJsonDictionary) throws {
            try self.init(
                product: jsonDictionary.value(forKey: CodingKeys.product)
            )
        }

        init(product: KeyValue) throws {
            self.product = try product.decode(Request.AdaptyPluginPaywallProduct.self)
        }

        func execute() async throws -> AdaptyJsonData {
            let product = try await Adapty.getPaywallProduct(
                vendorProductId: product.vendorProductId,
                adaptyProductId: product.adaptyProductId,
                offerTypeWithIdentifier: product.offerTypeWithIdentifier,
                variationId: product.variationId,
                paywallABTestName: product.paywallABTestName,
                paywallName: product.paywallName
            )
            let result = try await Adapty.makePurchase(product: product)
            return .success(result)
        }
    }
}

public extension AdaptyPlugin {
    @objc static func makePurchase(
        product: String,
        _ completion: @escaping AdaptyJsonDataCompletion
    ) {
        typealias CodingKeys = Request.MakePurchase.CodingKeys
        execute(with: completion) { try Request.MakePurchase(
            product: .init(key: CodingKeys.product, value: product)
        ) }
    }
}
