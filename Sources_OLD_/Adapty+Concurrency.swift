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


    /// Link purchased transaction with paywall's variationId.
    ///
    /// In [Observer mode](https://docs.adapty.io/docs/ios-observer-mode), Adapty SDK doesn't know, where the purchase was made from. If you display products using our [Paywalls](https://docs.adapty.io/docs/paywall) or [A/B Tests](https://docs.adapty.io/docs/ab-test), you can manually assign variation to the purchase. After doing this, you'll be able to see metrics in Adapty Dashboard.
    ///
    /// - Parameters:
    ///   - variationId:  A string identifier of variation. You can get it using variationId property of ``AdaptyPaywall``.
    ///   - transaction: A purchased transaction (note, that this method is suitable only for Store Kit version 1) [SKPaymentTransaction](https://developer.apple.com/documentation/storekit/skpaymenttransaction).
    /// - Throws: An ``AdaptyError`` object
    public nonisolated static func setVariationId(
        _ variationId: String,
        forPurchasedTransaction transaction: SKPaymentTransaction
    ) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            Adapty.setVariationId(variationId, forPurchasedTransaction: transaction) { error in
                if let error {
                    return continuation.resume(throwing: error)
                }
                continuation.resume(
                    returning: ()
                )
            }
        }
    }

    /// Link purchased transaction with paywall's variationId.
    ///
    /// In [Observer mode](https://docs.adapty.io/docs/ios-observer-mode), Adapty SDK doesn't know, where the purchase was made from. If you display products using our [Paywalls](https://docs.adapty.io/docs/paywall) or [A/B Tests](https://docs.adapty.io/docs/ab-test), you can manually assign variation to the purchase. After doing this, you'll be able to see metrics in Adapty Dashboard.
    ///
    /// - Parameters:
    ///   - variationId:  A string identifier of variation. You can get it using variationId property of `AdaptyPaywall`.
    ///   - transaction: A purchased transaction (note, that this method is suitable only for Store Kit version 2) [Transaction](https://developer.apple.com/documentation/storekit/transaction).
    /// - Throws: An ``AdaptyError`` object
    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
    public nonisolated static func setVariationId(
        _ variationId: String,
        forPurchasedTransaction transaction: Transaction
    ) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            Adapty.setVariationId(variationId, forPurchasedTransaction: transaction) { error in
                if let error {
                    return continuation.resume(throwing: error)
                }
                continuation.resume(
                    returning: ()
                )
            }
        }
    }

}
