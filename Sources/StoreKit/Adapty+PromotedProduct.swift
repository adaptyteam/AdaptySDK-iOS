//
//  Adapty+PromotedProduct.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 30.09.2026.
//

import Foundation

 extension Adapty {
    package nonisolated static func restorePromotedProduct(
        purchaseIntentId: String,
        vendorProductId: String,
        billingPlan: AdaptySubscriptionBillingPlan?,
        subscriptionOfferIdentifier: AdaptySubscriptionOffer.Identifier?
    ) async throws(AdaptyError) -> AdaptyPromotedProduct {
        let sdk = try await Adapty.activatedSDK

        let (skProduct, subscriptionPricingTerms, subscriptionOffer) = try await sdk.restoreProduct(
            vendorProductId: vendorProductId,
            billingPlan: billingPlan,
            subscriptionOfferIdentifier: subscriptionOfferIdentifier
        )

        return AdaptyPromotedProduct(
            purchaseIntentId: purchaseIntentId,
            skProduct: skProduct,
            subscriptionPricingTerms: subscriptionPricingTerms,
            subscriptionOffer: subscriptionOffer,
            skOffer: nil
        )
    }
}
