//
//  Adapty+MakePurchase.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 23.05.2023
//

import StoreKit

public extension Adapty {
    /// To make the purchase, you have to call this method.
    ///
    /// Read more on the [Adapty Documentation](https://docs.adapty.io/v2.0.0/docs/ios-making-purchases)
    ///
    /// - Parameters:
    ///   - product: a ``AdaptyPaywallProduct`` object retrieved from the paywall.
    /// - Returns: The ``AdaptyPurchaseResult`` object.
    /// - Throws: An ``AdaptyError`` object
    nonisolated static func makePurchase(
        product: AdaptyPaywallProduct
    ) async throws(AdaptyError) -> AdaptyPurchaseResult {
        try await withActivatedSDK(
            methodName: .makePurchase,
            logParams: [
                "paywall_name": product.paywallName,
                "variation_id": product.variationId,
                "product_id": product.vendorProductId,
            ]
        ) { sdk throws(AdaptyError) in
            guard let purchaser = sdk.purchaser else { throw .cantMakePayments() }

            let appAccountToken: UUID? =
                if let customerUserId = sdk.userId?.customerId {
                    sdk.profileStorage.getAppAccountToken() ?? UUID(uuidString: customerUserId)
                } else {
                    nil
                }

            return try await purchaser.makePurchase(
                userId: sdk.profileStorage.userId,
                appAccountToken: appAccountToken,
                product: product
            )
        }
    }

    /// To make the purchase, you have to call this method.
    ///
    /// Read more on the [Adapty Documentation](https://docs.adapty.io/v2.0.0/docs/ios-making-purchases)
    ///
    /// - Parameters:
    ///   - product: a ``AdaptyDeferredProduct`` object retrieved from the delegate.
    /// - Returns: The ``AdaptyPurchaseResult`` object.
    /// - Throws: An ``AdaptyError`` object
    nonisolated static func makePurchase(
        product: AdaptyDeferredProduct
    ) async throws(AdaptyError) -> AdaptyPurchaseResult {
        try await withActivatedSDK(
            methodName: .makePurchase,
            logParams: [
                "product_id": product.vendorProductId,
            ]
        ) { sdk throws(AdaptyError) in
            guard let manager = sdk.sk1QueueManager else { throw .cantMakePayments() }
            return try await manager.makePurchase(product: product)
        }
    }

    /// To restore purchases, you have to call this method.
    ///
    /// Read more on the [Adapty Documentation](https://docs.adapty.io/v2.0.0/docs/ios-making-purchases#restoring-purchases)
    ///
    /// - Returns: The ``AdaptyProfile`` object. This model contains info about access levels, subscriptions, and non-subscription purchases. Generally, you have to check only access level status to determine whether the user has premium access to the app.
    /// - Throws: An ``AdaptyError`` object
    nonisolated static func restorePurchases() async throws(AdaptyError) -> AdaptyProfile {
        try await withActivatedSDK(methodName: .restorePurchases) { sdk throws(AdaptyError) in
            let userId = sdk.profileStorage.userId
            if let profile = try await sdk.syncTransactions(for: userId) {
                return profile
            }

            let manager = try await sdk.createdProfileManager
            if manager.isNotEqualProfileId(userId) {
                throw .profileWasChanged()
            }

            return await manager.getProfile()
        }
    }
}
