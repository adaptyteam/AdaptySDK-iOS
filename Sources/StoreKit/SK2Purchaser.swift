//
//  SK2Purchaser.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 23.10.2024
//

import StoreKit

private let log = Log.sk2TransactionManager

actor SK2Purchaser {
    private let purchaseValidator: PurchaseValidator
    private let storage: VariationIdStorage

    init(purchaseValidator: PurchaseValidator, productsManager _: StoreKitProductsManager, storage: VariationIdStorage) {
        self.purchaseValidator = purchaseValidator
        self.storage = storage
    }

    func makePurchase(
        profileId _: String,
        product: AdaptyPaywallProduct
    ) async throws -> AdaptyPurchaseResult {
        guard #available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *),
              let sk2Product = product.sk2Product
        else {
            throw AdaptyError.cantMakePayments()
        }

        return try await makePurchase(sk2Product, product.variationId)
    }

    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
    private func makePurchase(
        _ sk2Product: SK2Product,
        _ variationId: String?
    ) async throws -> AdaptyPurchaseResult {
        let options: Set<Product.PurchaseOption> = Set()

        let stamp = Log.stamp
        await storage.setVariationIds(variationId, for: sk2Product.id)

        await Adapty.trackSystemEvent(AdaptyAppleRequestParameters(
            methodName: .productPurchase,
            stamp: stamp,
            params: [
                "product_id": sk2Product.id,
            ]
        ))

        let purchaseResult: Product.PurchaseResult
        do {
            purchaseResult = try await sk2Product.purchase(options: options)
        } catch {
            storage.removeVariationIds(for: sk2Product.id)
            await Adapty.trackSystemEvent(AdaptyAppleResponseParameters(
                methodName: .productPurchase,
                stamp: stamp,
                error: error.localizedDescription
            ))
            log.error("Failed to purchase product: \(sk2Product.id) \(error.localizedDescription)")
            throw StoreKitManagerError.productPurchaseFailed(error).asAdaptyError
        }

        let sk2Transaction: SK2Transaction
        switch purchaseResult {
        case let .success(.verified(transaction)):
            await Adapty.trackSystemEvent(AdaptyAppleResponseParameters(
                methodName: .productPurchase,
                stamp: stamp,
                params: [
                    "verified": true,
                ]
            ))
            sk2Transaction = transaction
        case let .success(.unverified(_, error)):
            await Adapty.trackSystemEvent(AdaptyAppleResponseParameters(
                methodName: .productPurchase,
                stamp: stamp,
                error: error.localizedDescription
            ))
            log.error("Unverified purchase trunsaction of product: \(sk2Product.id) \(error.localizedDescription)")
            throw StoreKitManagerError.trunsactionUnverified(error).asAdaptyError
        case .pending:
            await Adapty.trackSystemEvent(AdaptyAppleResponseParameters(
                methodName: .productPurchase,
                stamp: stamp,
                params: [
                    "pending": true,
                ]
            ))
            log.info("Pending purchase product: \(sk2Product.id)")
            return .pending
        case .userCancelled:
            await Adapty.trackSystemEvent(AdaptyAppleResponseParameters(
                methodName: .productPurchase,
                stamp: stamp,
                params: [
                    "cancelled": true,
                ]
            ))
            log.info("User cancelled purchase product: \(sk2Product.id)")
            return .userCancelled
        @unknown default:
            await Adapty.trackSystemEvent(AdaptyAppleResponseParameters(
                methodName: .productPurchase,
                stamp: stamp,
                params: [
                    "unknown": true,
                ]
            ))
            log.error("Unknown purchase result of product: \(sk2Product.id)")
            throw StoreKitManagerError.productPurchaseFailed(nil).asAdaptyError
        }

        let purchasedTransaction = PurchasedTransaction(
            sk2Product: sk2Product,
            variationId: variationId,
            persistentVariationId: variationId,
            sk2Transaction: sk2Transaction
        )

        do {
            let response = try await purchaseValidator.validatePurchase(
                profileId: nil,
                transaction: purchasedTransaction,
                reason: .purchasing
            )

            storage.removeVariationIds(for: sk2Product.id)

            await sk2Transaction.finish()

            await Adapty.trackSystemEvent(AdaptyAppleRequestParameters(
                methodName: .finishTransaction,
                params: sk2Transaction.logParams
            ))

            log.info("Successfully purchased product: \(sk2Product.id) with transaction: \(sk2Transaction)")
            return .success(profile: response.value, transaction: sk2Transaction)
        } catch {
            throw StoreKitManagerError.trunsactionUnverified(error).asAdaptyError
        }
    }
}
