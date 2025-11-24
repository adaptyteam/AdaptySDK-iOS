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
    ) async throws(AdaptyError) {
        let variationId = variationId.trimmed.nonEmptyOrNil
        let transactionId = transactionId.trimmed
        // TODO: throw error if transactionId isEmpty

        return try await withActivatedSDK(methodName: .setVariationId, logParams: [
            "variation_id": variationId,
            "transaction_id": transactionId,
        ]) { sdk throws(AdaptyError) in
            let userId = sdk.profileStorage.userId
            try await sdk.sendTransactionId(
                transactionId,
                with: variationId,
                for: userId
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
    nonisolated static func reportTransaction(
        _ transaction: StoreKit.Transaction,
        withVariationId variationId: String? = nil
    ) async throws(AdaptyError) {
        let variationId = variationId.trimmed.nonEmptyOrNil
        try await withActivatedSDK(methodName: .reportTransaction, logParams: [
            "variation_id": variationId,
            "transaction_id": transaction.id,
        ]) { sdk throws(AdaptyError) in
            let userId = try await sdk.createdProfileManager.userId

            guard !transaction.isXcodeEnvironment else { return }

            let productOrNil = try? await sdk.productsManager.fetchProduct(
                id: transaction.productID,
                fetchPolicy: .returnCacheDataElseLoad
            ).asAdaptyProduct

            try await sdk.report(
                .init(
                    product: productOrNil,
                    transaction: transaction
                ),
                payload: .init(
                    userId: userId,
                    paywallVariationId: variationId,
                    persistentOnboardingVariationId: sdk.purchasePayloadStorage.onboardingVariationId()
                ),
                reason: .setVariation
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
    nonisolated static func reportTransaction(
        _ signedTransaction: StoreKit.VerificationResult<StoreKit.Transaction>,
        withVariationId variationId: String? = nil
    ) async throws(AdaptyError) {
        let transaction: StoreKit.Transaction
        do {
            transaction = try signedTransaction.payloadValue
        } catch {
            throw StoreKitManagerError.transactionUnverified(error).asAdaptyError
        }

        return try await reportTransaction(transaction, withVariationId: variationId)
    }

    /// Link product purchase result with paywall's variationId.
    ///
    /// In [Observer mode](https://docs.adapty.io/docs/ios-observer-mode), Adapty SDK doesn't know, where the purchase was made from. If you display products using our [Paywalls](https://docs.adapty.io/docs/paywall) or [A/B Tests](https://docs.adapty.io/docs/ab-test), you can manually assign variation to the purchase. After doing this, you'll be able to see metrics in Adapty Dashboard.
    ///
    /// - Parameters:
    ///   - purchaseResult: A product purchase result (note, that this method is suitable only for Store Kit version 2) [Product.PurchaseResult](https://developer.apple.com/documentation/storekit/product/purchaseresult).
    ///   - withVariationId:  A string identifier of variation. You can get it using variationId property of `AdaptyPaywall`.
    /// - Throws: An ``AdaptyError`` object
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
