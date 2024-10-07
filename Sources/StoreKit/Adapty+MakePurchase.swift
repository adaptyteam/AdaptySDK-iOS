//
//  Adapty+MakePurchase.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 23.05.2023
//

import Foundation

extension Adapty {
    /// To make the purchase, you have to call this method.
    ///
    /// Read more on the [Adapty Documentation](https://docs.adapty.io/v2.0.0/docs/ios-making-purchases)
    ///
    /// - Parameters:
    ///   - product: a ``AdaptyPaywallProduct`` object retrieved from the paywall.
    /// - Returns: The ``AdaptyPurchasedInfo`` object.
    /// - Throws: An ``AdaptyError`` object
    public nonisolated static func makePurchase(product _: AdaptyPaywallProduct) async throws -> AdaptyPurchasedInfo {
        throw AdaptyError.cantMakePayments()
//        let logName = "make_purchase"
//        let logParams: EventParameters = [
//            "paywall_name": product.paywallName,
//            "variation_id": product.variationId,
//            "product_id": product.vendorProductId,
//        ]
//
//        guard SK1QueueManager.canMakePayments() else {
//            let stamp = Log.stamp
//            Adapty.trackSystemEvent(AdaptySDKMethodRequestParameters(methodName: logName, stamp: stamp, params: logParams))
//            let error = AdaptyError.cantMakePayments()
//            Adapty.trackSystemEvent(AdaptySDKMethodResponseParameters(methodName: logName, stamp: stamp, error: error.description))
//            completion(.failure(error))
//            return
//        }
//
//        async(completion, logName: logName, logParams: logParams) { manager, completion in
//            guard let discountId = product.promotionalOfferId else {
//                manager.sk1QueueManager.makePurchase(payment: SKPayment(product: product.skProduct), product: product, completion)
//                return
//            }
//
//            let profileId = manager.profileStorage.profileId
//
//            manager.httpSession.performSignSubscriptionOfferRequest(profileId: profileId, vendorProductId: product.vendorProductId, discountId: discountId) { result in
//                switch result {
//                case let .failure(error):
//                    completion(.failure(error))
//                case let .success(response):
//
//                    let payment = SKMutablePayment(product: product.skProduct)
//                    payment.applicationUsername = ""
//                    payment.paymentDiscount = response.discount(identifier: discountId)
//                    manager.sk1QueueManager.makePurchase(payment: payment, product: product, completion)
//                }
//            }
//        }
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
