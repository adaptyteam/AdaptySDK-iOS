//
//  Request.MakePromotedPurchase.swift
//  AdaptyPlugin
//
//  Created by Codex on 03.07.2026.
//

import Adapty
import Foundation

extension Request {
    struct MakePromotedPurchase: AdaptyPluginRequest {
        static let method = "make_promoted_purchase"
        let product: AdaptyPluginPromotedProduct

        enum CodingKeys: String, CodingKey {
            case product
        }

        func execute() async throws -> AdaptyJsonData {
            let result = try await Adapty.makePromotedPurchase(
                vendorProductId: product.vendorProductId,
                subscriptionOfferIdentifier: product.subscriptionOfferIdentifier
            )
            return .success(result)
        }
    }
}
