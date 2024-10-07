//
//  Adapty+MakePurchase.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 23.05.2023
//

import StoreKit

extension Adapty {
    /// To make the purchase, you have to call this method.
    ///
    /// Read more on the [Adapty Documentation](https://docs.adapty.io/v2.0.0/docs/ios-making-purchases)
    ///
    /// - Parameters:
    ///   - product: a ``AdaptyPaywallProduct`` object retrieved from the paywall.
    /// - Returns: The ``AdaptyPurchasedInfo`` object.
    /// - Throws: An ``AdaptyError`` object
    public nonisolated static func makePurchase(product: AdaptyPaywallProduct) async throws -> AdaptyPurchasedInfo {
        try await withActivatedSDK(
            methodName: .makePurchase,
            logParams: [
                "paywall_name": product.paywallName,
                "variation_id": product.variationId,
                "product_id": product.vendorProductId,
            ]
        ) { sdk in

            guard SKPaymentQueue.canMakePayments() else {
                throw AdaptyError.cantMakePayments()
            }

            guard let discountId = product.promotionalOfferId else {
                return try await sdk.sk1QueueManager.makePurchase(
                    payment: SKPayment(product: product.skProduct),
                    product: product
                )
            }

            let profileId = sdk.profileStorage.profileId

            do {
                let response = try await sdk.httpSession.signSubscriptionOffer(
                    profileId: profileId,
                    vendorProductId: product.vendorProductId,
                    discountId: discountId
                )

                let payment = SKMutablePayment(product: product.skProduct)
                payment.applicationUsername = ""
                payment.paymentDiscount = response.discount(identifier: discountId)

                return try await sdk.sk1QueueManager.makePurchase(
                    payment: payment,
                    product: product
                )
            } catch {
                throw error.asAdaptyError
            }
        }
    }

    /// To restore purchases, you have to call this method.
    ///
    /// Read more on the [Adapty Documentation](https://docs.adapty.io/v2.0.0/docs/ios-making-purchases#restoring-purchases)
    ///
    /// - Returns: The ``AdaptyProfile`` object. This model contains info about access levels, subscriptions, and non-subscription purchases. Generally, you have to check only access level status to determine whether the user has premium access to the app.
    /// - Throws: An ``AdaptyError`` object
    public nonisolated static func restorePurchases() async throws -> AdaptyProfile {
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
