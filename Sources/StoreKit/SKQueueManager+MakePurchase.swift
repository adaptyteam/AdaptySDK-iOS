//
//  SKQueueManager+MakePurchase.swift
//  Adapty
//
//  Created by Aleksei Valiano on 25.10.2022
//

import StoreKit

extension SKQueueManager {
    func makePurchase<T: AdaptyProduct>(payment: SKPayment, product: T, _ completion: @escaping AdaptyResultCompletion<AdaptyProfile>) {
        queue.async { [weak self] in
            let productId = payment.productIdentifier
            guard let self = self else { return }

            if let productVariationId = (product as? AdaptyPaywallProduct)?.variationId {
                self.variationsIds[productId] = productVariationId
            }

            self.makePurchasesProduct[productId] = product

            if let handlers = self.makePurchasesCompletionHandlers[productId] {
                self.makePurchasesCompletionHandlers[productId] = handlers + [completion]
                return
            }

            self.makePurchasesCompletionHandlers[productId] = [completion]
            SKPaymentQueue.default().add(payment)
        }
    }

    func receivedFailedTransaction(_ transaction: SKPaymentTransaction) {
        queue.async { [weak self] in
            guard let self = self else { return }

            if !Adapty.Configuration.observerMode {
                SKPaymentQueue.default().finishTransaction(transaction)
                Log.verbose("SKQueueManager: finish faild transaction \(transaction)")
            }

            let productId = transaction.payment.productIdentifier

            self.variationsIds.removeValue(forKey: productId)
            self.makePurchasesProduct.removeValue(forKey: productId)

            let error = SKManagerError.productPurchaseFailed(transaction.error).asAdaptyError

            self.callMakePurchasesCompletionHandlers(productId, .failure(error))
        }
    }

    func receivedPurchasedTransaction(_ transaction: SKPaymentTransaction) {
        queue.async { [weak self] in
            guard let self = self else { return }

            let productId = transaction.payment.productIdentifier
            let variationId = self.variationsIds[productId]
            let product = self.makePurchasesProduct[productId]

            let purchaseProductInfo = PurchaseProductInfo(product, variationId, transaction)

            self.receiptValidator.validateReceipt(purchaseProductInfo: purchaseProductInfo) { [weak self] result in
                guard let self = self else { return }
                if result.error == nil {
                    self.variationsIds.removeValue(forKey: productId)
                    self.makePurchasesProduct.removeValue(forKey: productId)

                    if !Adapty.Configuration.observerMode {
                        SKPaymentQueue.default().finishTransaction(transaction)
                        Log.info("SKQueueManager: finish purchased transaction \(transaction)")
                    }
                }
                self.callMakePurchasesCompletionHandlers(productId, result.map { $0.value })
            }
        }
    }

    func callMakePurchasesCompletionHandlers(_ productId: String,
                                             _ result: AdaptyResult<AdaptyProfile>) {
        queue.async { [weak self] in
            guard let self = self else { return }

            switch result {
            case let .failure(error):
                Log.error("Failed to purchase product: \(productId) \(error.localizedDescription)")
            case .success:
                Log.info("Successfully purchased product: \(productId).")
            }

            guard let handlers = self.makePurchasesCompletionHandlers.removeValue(forKey: productId) else {
                Log.error("Not found makePurchasesCompletionHandlers for \(productId)")
                return
            }

            for completion in handlers { completion(result) }
        }
    }
}
