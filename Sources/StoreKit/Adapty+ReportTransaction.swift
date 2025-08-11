//
//  Adapty+ReportTransaction.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 06.10.2024
//

import StoreKit

public extension Adapty {
    package nonisolated static func reportTransaction(
        _ transactionId: String,
        withVariationId variationId: String?
    ) async throws(AdaptyError) -> AdaptyProfile {
        let variationId = variationId.trimmed.nonEmptyOrNil
        let transactionId = transactionId.trimmed
        // TODO: throw error if transactionId isEmpty

        return try await withActivatedSDK(methodName: .setVariationId, logParams: [
            "variation_id": variationId,
            "transaction_id": transactionId,
        ]) { sdk throws(AdaptyError) in
            let userId = sdk.profileStorage.userId
            let response = try await sdk.reportTransaction(
                userId: userId,
                transactionId: transactionId,
                variationId: variationId
            )
            return response.value
        }
    }

    /// Link purchased transaction with paywall's variationId.
    ///
    /// In [Observer mode](https://docs.adapty.io/docs/ios-observer-mode), Adapty SDK doesn't know, where the purchase was made from. If you display products using our [Paywalls](https://docs.adapty.io/docs/paywall) or [A/B Tests](https://docs.adapty.io/docs/ab-test), you can manually assign variation to the purchase. After doing this, you'll be able to see metrics in Adapty Dashboard.
    ///
    /// - Parameters:
    ///   - transaction: A purchased transaction (note, that this method is suitable only for Store Kit version 1) [SKPaymentTransaction](https://developer.apple.com/documentation/storekit/skpaymenttransaction).
    ///   - withVariationId:  A string identifier of variation. You can get it using variationId property of ``AdaptyPaywall``.
    /// - Throws: An ``AdaptyError`` object
    nonisolated static func reportTransaction(
        _ transaction: StoreKit.SKPaymentTransaction,
        withVariationId variationId: String? = nil
    ) async throws(AdaptyError) {
        let variationId = variationId.trimmed.nonEmptyOrNil
        try await withActivatedSDK(methodName: .reportSK1Transaction, logParams: [
            "variation_id": variationId,
            "transaction_id": transaction.transactionIdentifier,
        ]) { sdk throws(AdaptyError) in
            guard transaction.transactionState == .purchased || transaction.transactionState == .restored,
                  let id = transaction.transactionIdentifier
            else {
                throw .wrongParamPurchasedTransaction()
            }

            let userId = try await sdk.createdProfileManager.userId

            try await sdk.reportTransaction(
                userId: userId,
                transaction: SK1TransactionWithIdentifier(transaction, id: id),
                variationId: variationId
            )
        }
    }

    /// Link purchased transaction with paywall's variationId.
    ///
    /// In [Observer mode](https://docs.adapty.io/docs/ios-observer-mode), Adapty SDK doesn't know, where the purchase was made from. If you display products using our [Paywalls](https://docs.adapty.io/docs/paywall) or [A/B Tests](https://docs.adapty.io/docs/ab-test), you can manually assign variation to the purchase. After doing this, you'll be able to see metrics in Adapty Dashboard.
    ///
    /// - Parameters:
    ///   - transaction: A purchased transaction (note, that this method is suitable only for Store Kit version 2) [Transaction](https://developer.apple.com/documentation/storekit/transaction).
    ///   - withVariationId:  A string identifier of variation. You can get it using variationId property of `AdaptyPaywall`.
    /// - Throws: An ``AdaptyError`` object
    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
    nonisolated static func reportTransaction(
        _ transaction: StoreKit.Transaction,
        withVariationId variationId: String? = nil
    ) async throws(AdaptyError) {
        let variationId = variationId.trimmed.nonEmptyOrNil
        try await withActivatedSDK(methodName: .reportSK2Transaction, logParams: [
            "variation_id": variationId,
            "transaction_id": transaction.unfIdentifier,
        ]) { sdk throws(AdaptyError) in
            let userId = try await sdk.createdProfileManager.userId

            try await sdk.reportTransaction(
                userId: userId,
                transaction: transaction,
                variationId: variationId
            )
        }
    }

    /// Link purchased transaction with paywall's variationId.
    ///
    /// In [Observer mode](https://docs.adapty.io/docs/ios-observer-mode), Adapty SDK doesn't know, where the purchase was made from. If you display products using our [Paywalls](https://docs.adapty.io/docs/paywall) or [A/B Tests](https://docs.adapty.io/docs/ab-test), you can manually assign variation to the purchase. After doing this, you'll be able to see metrics in Adapty Dashboard.
    ///
    /// - Parameters:
    ///   - transaction: A purchased verification result of transaction (note, that this method is suitable only for Store Kit version 2) [Transaction](https://developer.apple.com/documentation/storekit/verificationresult).
    ///   - withVariationId:  A string identifier of variation. You can get it using variationId property of `AdaptyPaywall`.
    /// - Throws: An ``AdaptyError`` object
    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
    nonisolated static func reportTransaction(
        _ transaction: StoreKit.VerificationResult<StoreKit.Transaction>,
        withVariationId variationId: String? = nil
    ) async throws(AdaptyError) {
        let sk2Transaction: SK2Transaction
        do {
            sk2Transaction = try transaction.payloadValue
        } catch {
            throw StoreKitManagerError.transactionUnverified(error).asAdaptyError
        }

        return try await reportTransaction(sk2Transaction, withVariationId: variationId)
    }

    /// Link product purchase result with paywall's variationId.
    ///
    /// In [Observer mode](https://docs.adapty.io/docs/ios-observer-mode), Adapty SDK doesn't know, where the purchase was made from. If you display products using our [Paywalls](https://docs.adapty.io/docs/paywall) or [A/B Tests](https://docs.adapty.io/docs/ab-test), you can manually assign variation to the purchase. After doing this, you'll be able to see metrics in Adapty Dashboard.
    ///
    /// - Parameters:
    ///   - purchaseResult: A product purchase result (note, that this method is suitable only for Store Kit version 2) [Product.PurchaseResult](https://developer.apple.com/documentation/storekit/product/purchaseresult).
    ///   - withVariationId:  A string identifier of variation. You can get it using variationId property of `AdaptyPaywall`.
    /// - Throws: An ``AdaptyError`` object
    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
    nonisolated static func reportPurchaseResult(
        _ purchaseResult: StoreKit.Product.PurchaseResult,
        withVariationId variationId: String? = nil
    ) async throws(AdaptyError) {
        switch purchaseResult {
        case let .success(verificationResult):
            try await reportTransaction(verificationResult, withVariationId: variationId)
        case .userCancelled:
            return
        case .pending:
            throw StoreKitManagerError.paymentPendingError().asAdaptyError
        @unknown default:
            throw StoreKitManagerError.productPurchaseFailed(nil).asAdaptyError
        }
    }
}
