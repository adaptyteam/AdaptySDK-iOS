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
    @available(visionOS, unavailable)
    nonisolated static func makePurchase(
        product: AdaptyPaywallProduct
//        confirmIn viewController: UIViewController? = nil
    ) async throws -> AdaptyPurchaseResult {
        try await withActivatedSDK(
            methodName: .makePurchase,
            logParams: [
                "paywall_name": product.paywallName,
                "variation_id": product.variationId,
                "product_id": product.vendorProductId,
//                "view_controller_available": viewController != nil,
            ]
        ) { sdk in

            guard #available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *) else {
                guard let manager = sdk.sk1QueueManager else { throw AdaptyError.cantMakePayments() }

                return try await manager.makePurchase(
                    profileId: sdk.profileStorage.profileId,
                    product: product
                )
            }

            guard let manager = sdk.sk2Purchaser else { throw AdaptyError.cantMakePayments() }

            return try await manager.makePurchase(
                profileId: sdk.profileStorage.profileId,
                product: product,
                confirmIn: nil
//                confirmIn: viewController
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
    nonisolated static func makePurchase(product: AdaptyDeferredProduct) async throws -> AdaptyPurchaseResult {
        try await withActivatedSDK(
            methodName: .makePurchase,
            logParams: [
                "product_id": product.vendorProductId,
            ]
        ) { sdk in
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
    nonisolated static func restorePurchases() async throws -> AdaptyProfile {
        try await withActivatedSDK(methodName: .restorePurchases) { sdk in
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
