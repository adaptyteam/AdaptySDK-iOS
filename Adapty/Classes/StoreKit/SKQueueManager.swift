//
//  SKQueueManager.swift
//  Adapty
//
//  Created by Aleksei Valiano on 25.10.2022
//

import StoreKit

protocol VariationIdStorage {
    func getVariationsIds() -> [String: String]
    func setVariationsIds(_: [String: String])
}

extension Adapty {
    /// Call this method to have StoreKit present a sheet enabling the user to redeem codes provided by your app.
    public static func presentCodeRedemptionSheet() {
        #if swift(>=5.3) && os(iOS) && !targetEnvironment(macCatalyst)
            async(nil) { _, completion in
                if #available(iOS 14.0, *) {
                    SKPaymentQueue.default().presentCodeRedemptionSheet()
                } else {
                    Log.error("Presenting code redemption sheet is available only for iOS 14 and higher.")
                }
                completion(nil)
            }
        #endif
    }
}

protocol ReceiptValidator {
    func validateReceipt(refreshIfEmpty: Bool, _ completion: @escaping AdaptyResultCompletion<VH<AdaptyProfile>>)

    func validateReceipt(purchaseProductInfo: PurchaseProductInfo, _ completion: @escaping AdaptyResultCompletion<VH<AdaptyProfile>>)
}

final class SKQueueManager: NSObject {
    let queue: DispatchQueue

    var receiptValidator: ReceiptValidator!

    var restorePurchasesCompletionHandlers: [AdaptyResultCompletion<AdaptyProfile>]?
    var totalRestoredPurchases = 0

    var makePurchasesCompletionHandlers = [String: [AdaptyResultCompletion<AdaptyProfile>]]()
    var makePurchasesProduct = [String: AdaptyProduct]()

    var storage: VariationIdStorage

    var variationsIds: [String: String] {
        didSet {
            storage.setVariationsIds(variationsIds)
        }
    }

    init(queue: DispatchQueue, storage: VariationIdStorage) {
        self.queue = queue
        self.storage = storage
        variationsIds = storage.getVariationsIds()
        super.init()
    }

    static func canMakePayments() -> Bool {
        SKPaymentQueue.canMakePayments()
    }

    func startObserving(receiptValidator: ReceiptValidator) {
        self.receiptValidator = receiptValidator
        SKPaymentQueue.default().add(self)

        NotificationCenter.default.addObserver(forName: Application.willTerminateNotification, object: nil, queue: .main) { [weak self] _ in
            if let self = self { SKPaymentQueue.default().remove(self) }
        }
    }
}

extension SKQueueManager: SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        transactions.forEach { transaction in
            switch transaction.transactionState {
            case .purchased:
                receivedPurchasedTransaction(transaction)

            case .failed:
                receivedFailedTransaction(transaction)

            case .restored:
                receivedRestoredTransaction(transaction)

            case .deferred, .purchasing: break
            @unknown default: break
            }
        }
    }

    #if os(iOS) && !targetEnvironment(macCatalyst)
        func paymentQueue(_ queue: SKPaymentQueue, shouldAddStorePayment payment: SKPayment, for product: SKProduct) -> Bool {
            guard Adapty.delegate != nil else { return true }
            Adapty.callDelegate { delegate in
                let deferedProduct = AdaptyDeferredProduct(skProduct: product, payment: payment)
                delegate.paymentQueue(shouldAddStorePaymentFor: deferedProduct) { [weak self] completion in
                    self?.makePurchase(payment: payment, product: deferedProduct) { result in
                        completion?(result)
                    }
                }
            }
            return false
        }
    #endif

    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        receiveRestoredTransactionsFinished(nil)
    }

    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        receiveRestoredTransactionsFinished(SKManagerError.receiveRestoredTransactionsFailed(error).asAdaptyError)
    }

    func paymentQueue(_ queue: SKPaymentQueue, didRevokeEntitlementsForProductIdentifiers productIdentifiers: [String]) {
        // TODO: validate reciept
    }
}
