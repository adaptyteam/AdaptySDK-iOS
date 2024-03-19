//
//  SK1QueueManager.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 25.10.2022
//

import StoreKit

protocol VariationIdStorage {
    func getVariationsIds() -> [String: String]?
    func setVariationsIds(_: [String: String])
    func getPersistentVariationsIds() -> [String: String]?
    func setPersistentVariationsIds(_: [String: String])
}

internal final class SK1QueueManager: NSObject {
    let queue: DispatchQueue

    var purchaseValidator: PurchaseValidator! // TODO: need refactoring

    var makePurchasesCompletionHandlers = [String: [AdaptyResultCompletion<AdaptyPurchasedInfo>]]()
    var makePurchasesProduct = [String: AdaptyProduct]()

    private var storage: VariationIdStorage
    var skProductsManager: SKProductsManager

    private(set) var variationsIds: [String: String]
    private(set) var persistentVariationsIds: [String: String]

    private(set) var _sk2TransactionObserver: Any?

    init(queue: DispatchQueue, storage: VariationIdStorage, skProductsManager: SKProductsManager) {
        self.queue = queue
        self.storage = storage
        variationsIds = storage.getVariationsIds() ?? [:]
        if let persistent = storage.getPersistentVariationsIds() {
            persistentVariationsIds = persistent
        } else {
            persistentVariationsIds = variationsIds
            storage.setPersistentVariationsIds(variationsIds)
        }
        self.skProductsManager = skProductsManager

        super.init()

        if #available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *) {
            _sk2TransactionObserver = SK2TransactionObserver(delegate: self)
        }
    }

    func setVariationId(_ variationId: String, for productId: String) {
        if variationId != variationsIds.updateValue(variationId, forKey: productId) {
            Adapty.logSystemEvent(AdaptyInternalEventParameters(eventName: "didset_variations_ids", params: [
                "variation_by_product": .value(variationsIds),
            ]))
            storage.setVariationsIds(variationsIds)
        }

        if variationId != persistentVariationsIds.updateValue(variationId, forKey: productId) {
            Adapty.logSystemEvent(AdaptyInternalEventParameters(eventName: "didset_variations_ids_persistent", params: [
                "variation_by_product": .value(variationsIds),
            ]))
            storage.setPersistentVariationsIds(variationsIds)
        }
    }

    func removeVariationId(for productId: String) {
        guard variationsIds.removeValue(forKey: productId) != nil else { return }
        Adapty.logSystemEvent(AdaptyInternalEventParameters(eventName: "didset_variations_ids", params: [
            "variation_by_product": .value(variationsIds),
        ]))
        storage.setVariationsIds(variationsIds)
    }

    static func canMakePayments() -> Bool {
        SKPaymentQueue.canMakePayments()
    }

    func startObserving(purchaseValidator: PurchaseValidator) {
        self.purchaseValidator = purchaseValidator
        SKPaymentQueue.default().add(self)

        NotificationCenter.default.addObserver(forName: Application.willTerminateNotification, object: nil, queue: .main) { [weak self] _ in
            if let self { SKPaymentQueue.default().remove(self) }
        }
    }
}

extension SK1QueueManager: SKPaymentTransactionObserver {
    func paymentQueue(_: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        transactions.forEach { transaction in

            let logParams = transaction.ext.logParams

            Adapty.logSystemEvent(AdaptyAppleEventQueueHandlerParameters(
                eventName: "updated_transaction",
                params: logParams,
                error: transaction.error.map { "\($0.localizedDescription). Detail: \($0)" }
            ))

            switch transaction.transactionState {
            case .purchased:
                receivedPurchasedTransaction(transaction)
            case .failed:
                receivedFailedTransaction(transaction)
            case .restored:
                if !Adapty.Configuration.observerMode {
                    SKPaymentQueue.default().finishTransaction(transaction)
                    Adapty.logSystemEvent(AdaptyAppleRequestParameters(methodName: "finish_transaction", params: logParams))
                    Log.verbose("SK1QueueManager: finish restored transaction \(transaction)")
                }
            case .deferred, .purchasing: break
            @unknown default: break
            }
        }
    }

    #if !os(watchOS)
        func paymentQueue(_: SKPaymentQueue, shouldAddStorePayment payment: SKPayment, for product: SKProduct) -> Bool {
            guard let delegate = Adapty.delegate else { return true }

            let deferredProduct = AdaptyDeferredProduct(sk1Product: product, payment: payment)
            return delegate.shouldAddStorePayment(for: deferredProduct, defermentCompletion: { [weak self] completion in
                self?.makePurchase(payment: payment, product: deferredProduct) { result in
                    completion?(result)
                }
            })
        }
    #endif

    func paymentQueueRestoreCompletedTransactionsFinished(_: SKPaymentQueue) {
        Adapty.logSystemEvent(AdaptyAppleEventQueueHandlerParameters(eventName: "restore_completed_transactions_finished"))
        Log.verbose("SK1QueueManager: Restore сompleted transactions finished.")
    }

    func paymentQueue(_: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        Adapty.logSystemEvent(AdaptyAppleEventQueueHandlerParameters(eventName: "restore_completed_transactions_failed", error: "\(error.localizedDescription). Detail: \(error)"))
        Log.error("SK1QueueManager: Restore сompleted transactions failed with error: \(error)")
    }

    func paymentQueue(_: SKPaymentQueue, didRevokeEntitlementsForProductIdentifiers productIdentifiers: [String]) {
        Adapty.logSystemEvent(AdaptyAppleEventQueueHandlerParameters(eventName: "did_revoke_entitlements", params: ["product_ids": .value(productIdentifiers)]))

        // TODO: validate receipt
    }
}
