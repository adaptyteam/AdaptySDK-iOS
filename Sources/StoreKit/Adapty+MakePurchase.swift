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
            let userId = sdk.userId ?? sdk.profileStorage.userId
            let appAccountToken: UUID? =
                if let customerUserId = userId.customerId {
                    sdk.profileStorage.appAccountToken() ?? UUID(uuidString: customerUserId)
                } else {
                    nil
                }

            return try await purchaser.makePurchase(
                userId: userId,
                appAccountToken: appAccountToken,
                product: product
            )
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
            let manager = try await sdk.createdProfileManager
            try await sdk.syncTransactionHistory(for: manager.userId, forceSync: true)
            return await manager.fetchProfile()
        }
    }
}
