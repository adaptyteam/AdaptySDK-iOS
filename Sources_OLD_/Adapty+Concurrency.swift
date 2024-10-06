//
//  Adapty+Concurrency.swift
//  AdaptySDK
//
//  Created by larryonoff on 4/26/22.
//

import StoreKit

extension Adapty {
    /// Once you have a ``AdaptyPaywall``, fetch corresponding products array using this method.
    ///
    /// Read more on the [Adapty Documentation](https://docs.adapty.io/v2.0.0/docs/displaying-products)
    ///
    /// - Parameters:
    ///   - paywall: the ``AdaptyPaywall`` for which you want to get a products
    /// - Returns: A result containing the ``AdaptyPaywallProduct`` objects array. The order will be the same as in the paywalls object. You can present them in your UI
    /// - Throws: An ``AdaptyError`` object
    public nonisolated static func getPaywallProducts(paywall: AdaptyPaywall) async throws -> [AdaptyPaywallProduct] {
        try await withCheckedThrowingContinuation { continuation in
            Adapty.getPaywallProducts(paywall: paywall) { result in
                switch result {
                case let .failure(error):
                    continuation.resume(throwing: error)
                case let .success(sk1Products):
                    continuation.resume(returning: sk1Products)
                }
            }
        }
    }

    /// Once you have an ``AdaptyPaywallProduct`` array, fetch introductory offers information for this products.
    ///
    /// Read more on the [Adapty Documentation](https://docs.adapty.io/docs/displaying-products#products-fetch-policy-and-intro-offer-eligibility-not-applicable-for-android)
    ///
    /// - Parameters:
    ///   - products: the ``AdaptyPaywallProduct`` array, for which information will be retrieved
    ///
    ///  - Returns: A dictionary where Key is vendorProductId and Value is corresponding ``AdaptyEligibility``.
    ///  - Throws: An ``AdaptyError`` object.
    public nonisolated static func getProductsIntroductoryOfferEligibility(products: [AdaptyPaywallProduct]) async throws -> [String: AdaptyEligibility] {
        try await withCheckedThrowingContinuation { continuation in
            Adapty.getProductsIntroductoryOfferEligibility(products: products) { result in
                switch result {
                case let .failure(error):
                    continuation.resume(throwing: error)
                case let .success(eligibilities):
                    continuation.resume(returning: eligibilities)
                }
            }
        }
    }

    /// Once you have an ``AdaptyPaywallProduct`` array, fetch introductory offers information for this products.
    ///
    /// Read more on the [Adapty Documentation](https://docs.adapty.io/docs/displaying-products#products-fetch-policy-and-intro-offer-eligibility-not-applicable-for-android)
    ///
    /// - Parameters:
    ///   - vendorProductIds: The products ids `String` array, for which information will be retrieved
    ///  - Returns: A dictionary where Key is vendorProductId and Value is corresponding ``AdaptyEligibility``.
    ///  - Throws: An ``AdaptyError`` object.
    public nonisolated static func getProductsIntroductoryOfferEligibility(vendorProductIds: [String]) async throws -> [String: AdaptyEligibility] {
        try await withCheckedThrowingContinuation { continuation in
            Adapty.getProductsIntroductoryOfferEligibility(vendorProductIds: vendorProductIds) { result in
                switch result {
                case let .failure(error):
                    continuation.resume(throwing: error)
                case let .success(eligibilities):
                    continuation.resume(returning: eligibilities)
                }
            }
        }
    }

    /// To make the purchase, you have to call this method.
    ///
    /// Read more on the [Adapty Documentation](https://docs.adapty.io/v2.0.0/docs/ios-making-purchases)
    ///
    /// - Parameters:
    ///   - product: a ``AdaptyPaywallProduct`` object retrieved from the paywall.
    /// - Returns: The ``AdaptyPurchasedInfo`` object.
    /// - Throws: An ``AdaptyError`` object
    public nonisolated static func makePurchase(product: AdaptyPaywallProduct) async throws -> AdaptyPurchasedInfo {
        try await withCheckedThrowingContinuation { continuation in
            Adapty.makePurchase(product: product) { result in
                switch result {
                case let .failure(error):
                    continuation.resume(throwing: error)
                case let .success(response):
                    continuation.resume(returning: response)
                }
            }
        }
    }
}
