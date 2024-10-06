//
//  Adapty+SetVariationId.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 06.10.2024
//

import StoreKit

extension Adapty {
    package nonisolated static func setVariationId(
        _ variationId: String,
        forTransactionId transactionId: String
    ) async throws {
        try await withActivatedSDK(methodName: .setVariationId, logParams: [
            "variation_id": variationId,
            "transaction_id": transactionId,
        ]) { sdk in
            let profileId = try await sdk.createdProfileManager.profileId

            do {
                try await sdk.httpSession.setTransactionVariationId(
                    profileId: profileId,
                    transactionId: transactionId,
                    variationId: variationId
                )
            } catch {
                throw error.asAdaptyError ?? AdaptyError.setTransactionVariationIdFailed(unknownError: error)
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
        forPurchasedTransaction sk1Transaction: SKPaymentTransaction
    ) async throws {
        try await withActivatedSDK(methodName: .setVariationIdSK1, logParams: [
            "variation_id": variationId,
            "transaction_id": sk1Transaction.transactionIdentifier,
        ]) { sdk in

            guard sk1Transaction.transactionState == .purchased || sk1Transaction.transactionState == .restored,
                  let transactionIdentifier = sk1Transaction.transactionIdentifier else {
                throw AdaptyError.wrongParamPurchasedTransaction()
            }

            let profileId = try await sdk.createdProfileManager.profileId

            let purchasedTransaction =
                if #available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *) {
                    await sdk.sk2ProductsManager.fillPurchasedTransaction(
                        variationId: variationId,
                        purchasedSK1Transaction: (value: sk1Transaction, id: transactionIdentifier)
                    )
                } else {
                    await sdk.sk1ProductsManager.fillPurchasedTransaction(
                        variationId: variationId,
                        purchasedSK1Transaction: (value: sk1Transaction, id: transactionIdentifier)
                    )
                }

            return try await sdk.validatePurchase(
                profileId: profileId,
                transaction: purchasedTransaction,
                reason: .setVariation
            )
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
        forPurchasedTransaction sk2Transaction: Transaction
    ) async throws {
        try await withActivatedSDK(methodName: .setVariationIdSK2, logParams: [
            "variation_id": variationId,
            "transaction_id": sk2Transaction.unfIdentifier,
        ]) { sdk in
            let profileId = try await sdk.createdProfileManager.profileId

            let purchasedTransaction = await sdk.sk2ProductsManager.fillPurchasedTransaction(
                variationId: variationId,
                purchasedSK2Transaction: sk2Transaction
            )

            return try await sdk.validatePurchase(
                profileId: profileId,
                transaction: purchasedTransaction,
                reason: .setVariation
            )
        }
    }
}
