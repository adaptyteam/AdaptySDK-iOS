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
            // TODO: Preserve the original promoted product across the plugin round trip.
            // The event JSON does not retain the StoreKit offer received in PurchaseIntent.offer.
            // make_promoted_purchase restores the offer from the product catalog instead;
            // purchase_intent_id is currently only copied, not used to retrieve the original product.
            // If the intent's win-back offer is absent from the catalog's upfront offers,
            // restoration fails with invalidOffer before StoreKit can start the purchase,
            // whereas the native path passes the original offer directly to StoreKit.
            let product = try await Adapty.restorePromotedProduct(
                purchaseIntentId: product.purchaseIntentId,
                vendorProductId: product.vendorProductId,
                billingPlan: product.billingPlan,
                subscriptionOfferIdentifier: product.subscriptionOfferIdentifier
            )
            let result = try await Adapty.makePurchase(product: product)
            return .success(result)
        }
    }
}
