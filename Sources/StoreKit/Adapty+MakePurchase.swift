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
            guard #available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *) else {
                guard let manager = sdk.sk1QueueManager else { throw AdaptyError.cantMakePayments() }

                return try await manager.makePurchase(
                    profileId: sdk.profileStorage.profileId,
                    product: product
                )
            }

            guard let manager = sdk.sk2Purchaser else { throw AdaptyError.cantMakePayments() }

            let profileId: String
            let customerUserId: String?

            if let profile = sdk.profileManager?.profile.value {
                profileId = profile.profileId
                customerUserId = profile.customerUserId
            } else {
                profileId = sdk.profileStorage.profileId
                customerUserId = nil
            }

            return try await manager.makePurchase(
                profileId: profileId,
                customerUserId: customerUserId,
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
            guard let manager = sdk.sk1QueueManager else { throw AdaptyError.cantMakePayments() }
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
            let profileId = sdk.profileStorage.profileId
            if let response = try await sdk.transactionManager.syncTransactions(for: profileId) {
                return response.value
            }

            let manager = try await sdk.createdProfileManager
            if manager.profileId != profileId {
                throw AdaptyError.profileWasChanged()
            }

            return await manager.getProfile()
        }
    }
}
