//
//  Adapty+PaywallProducts.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 23.05.2023
//

import Foundation

extension Adapty {
    /// This method is intended to be used by cross-platform SDKs, we do not expect you to use it directly.
    package nonisolated static func getPaywallProduct(
        vendorProductId: String,
        adaptyProductId: String,
        promotionalOfferId: String?,
        variationId: String,
        paywallABTestName: String,
        paywallName: String
    ) async throws -> AdaptyPaywallProduct {
        let product = try await activatedSDK.productsManager.fetchProduct(
            id: vendorProductId,
            fetchPolicy: .returnCacheDataElseLoad
        )

        return AdaptyPaywallProduct(
            adaptyProductId: adaptyProductId,
            underlying: product,
            promotionalOfferId: promotionalOfferId,
            variationId: variationId,
            paywallABTestName: paywallABTestName,
            paywallName: paywallName
        )
    }

    /// Once you have a ``AdaptyPaywall``, fetch corresponding products array using this method.
    ///
    /// Read more on the [Adapty Documentation](https://docs.adapty.io/v2.0.0/docs/displaying-products)
    ///
    /// - Parameters:
    ///   - paywall: the ``AdaptyPaywall`` for which you want to get a products
    /// - Returns: A result containing the ``AdaptyPaywallProduct`` objects array. The order will be the same as in the paywalls object. You can present them in your UI
    /// - Throws: An ``AdaptyError`` object
    public nonisolated static func getPaywallProducts(paywall: AdaptyPaywall) async throws -> [AdaptyPaywallProduct] {
        try await withActivatedSDK(
            methodName: .getPaywallProducts,
            logParams: ["placement_id": paywall.placementId]
        ) { sdk in
            try await sdk.productsManager.fetchProductsInSameOrder(
                ids: paywall.vendorProductIds,
                fetchPolicy: .returnCacheDataElseLoad
            ).compactMap { AdaptyPaywallProduct(paywall: paywall, underlying: $0) }
        }
    }
}
