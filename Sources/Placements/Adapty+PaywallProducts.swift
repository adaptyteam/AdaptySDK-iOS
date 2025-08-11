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
            if #available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *) {
                if let manager = sdk.productsManager as? SK2ProductsManager {
                    return try await sdk.getSK2PaywallProducts(
                        paywall: paywall,
                        productsManager: manager
                    )
                }
            } else {
                if let manager = sdk.productsManager as? SK1ProductsManager {
                    return try await sdk.getSK1PaywallProducts(
                        paywall: paywall,
                        productsManager: manager
                    )
                }
            }
            return []
        }
    }

    nonisolated static func getPaywallProductsWithoutDeterminingOffer(paywall: AdaptyPaywall) async throws(AdaptyError) -> [AdaptyPaywallProductWithoutDeterminingOffer] {
        try await withActivatedSDK(
            methodName: .getPaywallProductsWithoutDeterminingOffer,
            logParams: ["placement_id": paywall.placement.id]
        ) { sdk throws(AdaptyError) in
            if #available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *) {
                if let manager = sdk.productsManager as? SK2ProductsManager {
                    return try await sdk.getSK2PaywallProductsWithoutOffers(
                        paywall: paywall,
                        productsManager: manager
                    )
                }
            } else {
                if let manager = sdk.productsManager as? SK1ProductsManager {
                    return try await sdk.getSK1PaywallProductsWithoutOffers(
                        paywall: paywall,
                        productsManager: manager
                    )
                }
            }
            return []
        }
    }

    package nonisolated static func getPaywallProduct(
        backendProduct: BackendProduct,
        paywallProductIndex: Int,
        subscriptionOfferIdentifier: AdaptySubscriptionOffer.Identifier?,
        variationId: String,
        paywallABTestName: String,
        paywallName: String,
        webPaywallBaseUrl: URL?
    ) async throws(AdaptyError) -> AdaptyPaywallProduct {
        let sdk = try await Adapty.activatedSDK

        if #available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *) {
            guard let manager = sdk.productsManager as? SK2ProductsManager else {
                throw .cantMakePayments()
            }
            return try await sdk.getSK2PaywallProduct(
                backendProduct: backendProduct,
                paywallProductIndex: paywallProductIndex,
                subscriptionOfferIdentifier: subscriptionOfferIdentifier,
                variationId: variationId,
                paywallABTestName: paywallABTestName,
                paywallName: paywallName,
                webPaywallBaseUrl: webPaywallBaseUrl,
                productsManager: manager
            )

        } else {
            guard let manager = sdk.productsManager as? SK1ProductsManager else {
                throw .cantMakePayments()
            }
            return try await sdk.getSK1PaywallProduct(
                backendProduct: backendProduct,
                paywallProductIndex: paywallProductIndex,
                subscriptionOfferIdentifier: subscriptionOfferIdentifier,
                variationId: variationId,
                paywallABTestName: paywallABTestName,
                paywallName: paywallName,
                productsManager: manager,
                webPaywallBaseUrl: webPaywallBaseUrl
            )
        }
    }

    package nonisolated static func persistOnboardingVariationId(
        _ variationId: String
    ) async {
        await Adapty.optionalSDK?.variationIdStorage.setOnboardingVariationId(variationId)
    }
}
