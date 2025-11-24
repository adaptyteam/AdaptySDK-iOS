//
//  Adapty+PaywallProducts.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 23.05.2023
//

import Foundation

public extension Adapty {
    /// Once you have a ``AdaptyPaywall``, fetch corresponding products array using this method.
    ///
    /// Read more on the [Adapty Documentation](https://docs.adapty.io/v2.0.0/docs/displaying-products)
    ///
    /// - Parameters:
    ///   - paywall: the ``AdaptyPaywall`` for which you want to get a products
    /// - Returns: A result containing the ``AdaptyPaywallProduct`` objects array. The order will be the same as in the paywalls object. You can present them in your UI
    /// - Throws: An ``AdaptyError`` object
    nonisolated static func getPaywallProducts(paywall: AdaptyPaywall) async throws(AdaptyError) -> [AdaptyPaywallProduct] {
        try await withActivatedSDK(
            methodName: .getPaywallProducts,
            logParams: ["placement_id": paywall.placement.id]
        ) { sdk throws(AdaptyError) in
            try await sdk.getPaywallProducts(
                paywall: paywall,
                productsManager: sdk.productsManager
            )
        }
    }

    nonisolated static func getPaywallProductsWithoutDeterminingOffer(paywall: AdaptyPaywall) async throws(AdaptyError) -> [AdaptyPaywallProductWithoutDeterminingOffer] {
        try await withActivatedSDK(
            methodName: .getPaywallProductsWithoutDeterminingOffer,
            logParams: ["placement_id": paywall.placement.id]
        ) { sdk throws(AdaptyError) in
            try await sdk.getPaywallProductsWithoutOffers(
                paywall: paywall,
                productsManager: sdk.productsManager
            )
        }
    }

    package nonisolated static func getPaywallProduct(
        adaptyProductId: String,
        productInfo: BackendProductInfo,
        paywallProductIndex: Int,
        subscriptionOfferIdentifier: AdaptySubscriptionOffer.Identifier?,
        variationId: String,
        paywallABTestName: String,
        paywallName: String,
        webPaywallBaseUrl: URL?
    ) async throws(AdaptyError) -> AdaptyPaywallProduct {
        let sdk = try await Adapty.activatedSDK
        return try await sdk.getPaywallProduct(
            adaptyProductId: adaptyProductId,
            productInfo: productInfo,
            paywallProductIndex: paywallProductIndex,
            subscriptionOfferIdentifier: subscriptionOfferIdentifier,
            variationId: variationId,
            paywallABTestName: paywallABTestName,
            paywallName: paywallName,
            webPaywallBaseUrl: webPaywallBaseUrl,
            productsManager: sdk.productsManager
        )
    }

    package nonisolated static func persistOnboardingVariationId(
        _ variationId: String
    ) async {
        await Adapty.optionalSDK?.purchasePayloadStorage.setOnboardingVariationId(variationId)
    }
}
