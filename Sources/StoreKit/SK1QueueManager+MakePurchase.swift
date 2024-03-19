//
//  SK1QueueManager+MakePurchase.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 25.10.2022
//

import StoreKit

extension SK1QueueManager {
    func makePurchase(payment: SKPayment, product: some AdaptyProduct, _ completion: @escaping AdaptyResultCompletion<AdaptyPurchasedInfo>) {
        queue.async { [weak self] in
            let productId = payment.productIdentifier
            guard let self else { return }

            if let productVariationId = (product as? AdaptyPaywallProduct)?.variationId {
                self.setVariationId(productVariationId, for: productId)
            }

            self.makePurchasesProduct[productId] = product

            if let handlers = self.makePurchasesCompletionHandlers[productId] {
                self.makePurchasesCompletionHandlers[productId] = handlers + [completion]
                return
            }

            self.makePurchasesCompletionHandlers[productId] = [completion]
            SKPaymentQueue.default().add(payment)
            Adapty.logSystemEvent(AdaptyAppleRequestParameters(methodName: "add_payment", params: [
                "product_id": .value(payment.productIdentifier),
            ]))
        }
    }

    func receivedFailedTransaction(_ transaction: SK1Transaction) {
        queue.async { [weak self] in
            guard let self else { return }

            if !Adapty.Configuration.observerMode {
                SKPaymentQueue.default().finishTransaction(transaction)
                Adapty.logSystemEvent(AdaptyAppleRequestParameters(methodName: "finish_transaction", params: transaction.ext.logParams))
                Log.verbose("SK1QueueManager: finish failed transaction \(transaction)")
            }

            let productId = transaction.payment.productIdentifier

            self.removeVariationId(for: productId)
            self.makePurchasesProduct.removeValue(forKey: productId)

            let error = SKManagerError.productPurchaseFailed(transaction.error).asAdaptyError

            self.callMakePurchasesCompletionHandlers(productId, .failure(error))
        }
    }

    func receivedPurchasedTransaction(_ transaction: SK1Transaction) {
        guard let transactionIdentifier = transaction.transactionIdentifier else {
            Log.error("SK1QueueManager: received purchased transaction without identifier")
            return
        }

        func fillPurchasedTransaction(
            manager: SK1QueueManager,
            purchasedSK1Transaction transaction: (value: SK1Transaction, id: String),
            _ completion: @escaping ((PurchasedTransaction) -> Void)
        ) {
            let productId = transaction.value.payment.productIdentifier
            let variationId: String? = manager.variationsIds[productId]
            let persistentVariationId: String? = manager.persistentVariationsIds[productId]

            if let product = manager.makePurchasesProduct[productId] {
                completion(PurchasedTransaction.withSK1Product(product.skProduct, variationId, persistentVariationId, purchasedSK1Transaction: transaction))
                return
            }

            manager.skProductsManager.fillPurchasedTransaction(
                variationId: variationId,
                persistentVariationId: persistentVariationId,
                purchasedSK1Transaction: transaction,
                completion
            )
        }

        queue.async { [weak self] in
            guard let self else { return }
            fillPurchasedTransaction(manager: self, purchasedSK1Transaction: (transaction, transactionIdentifier)) { [weak self] purchasedTransaction in
                let productId = purchasedTransaction.vendorProductId

                let isObserverMode = Adapty.Configuration.observerMode
                self?.purchaseValidator.validatePurchase(transaction: purchasedTransaction, reason: isObserverMode ? .observing : .purchasing) { result in
                    guard let self else { return }
                    if result.error == nil {
                        self.removeVariationId(for: productId)
                        self.makePurchasesProduct.removeValue(forKey: productId)

                        if !isObserverMode {
                            SKPaymentQueue.default().finishTransaction(transaction)
                            Adapty.logSystemEvent(AdaptyAppleRequestParameters(methodName: "finish_transaction", params: transaction.ext.logParams))
                            Log.info("SK1QueueManager: finish purchased transaction \(transaction)")
                        }
                    }
                    self.callMakePurchasesCompletionHandlers(productId, result.map {
                        AdaptyPurchasedInfo(profile: $0.value, transaction: transaction)
                    })
                }
            }
        }
    }

    func callMakePurchasesCompletionHandlers(
        _ productId: String,
        _ result: AdaptyResult<AdaptyPurchasedInfo>
    ) {
        queue.async { [weak self] in
            guard let self else { return }

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

            for completion in handlers {
                completion(result)
            }
        }
    }
}
