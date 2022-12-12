//
//  SKQueueManager+RestorePurchases.swift
//  Adapty
//
//  Created by Aleksei Valiano on 25.10.2022
//

import StoreKit

extension SKQueueManager {
    func restorePurchases(_ completion: @escaping AdaptyResultCompletion<AdaptyProfile>) {
        queue.async { [weak self] in
            guard let self = self else { return }
            if let handlers = self.restorePurchasesCompletionHandlers {
                self.restorePurchasesCompletionHandlers = handlers + [completion]
                return
            }

            self.restorePurchasesCompletionHandlers = [completion]
            self.totalRestoredPurchases = 0
            SKPaymentQueue.default().restoreCompletedTransactions()
        }
    }

    func callRestoreCompletionHandlers(_ result: AdaptyResult<AdaptyProfile>) {
        queue.async { [weak self] in
            guard let self = self else { return }
            guard let handlers = self.restorePurchasesCompletionHandlers else {
                Log.error("Not found restorePurchasesCompletionHandlers")
                return
            }
            self.restorePurchasesCompletionHandlers = nil
            for completion in handlers { completion(result) }
        }
    }

    func receivedRestoredTransaction(_ transaction: SKPaymentTransaction) {
        queue.async { [weak self] in
            self?.totalRestoredPurchases += 1
        }
        if !Adapty.Configuration.observerMode {
            SKPaymentQueue.default().finishTransaction(transaction)
            Log.verbose("SKQueueManager: finish restored transaction \(transaction)")
        }
    }

    func receiveRestoredTransactionsFinished(_ error: AdaptyError?) {
        queue.async { [weak self] in
            guard let self = self else { return }

            var error = error
            if let error = error {
                Log.error("Failed to restore purchases: \(error.localizedDescription)")
                self.callRestoreCompletionHandlers(.failure(error))
                return
            }

            #if os(iOS)
                if self.totalRestoredPurchases == 0 {
                    error = SKManagerError.noPurchasesToRestore().asAdaptyError
                    Log.verbose("Successfully restored zero purchases.")
                }
            #endif

            if error == nil {
                Log.verbose("Successfully restored purchases.")
            }

            self.receiptValidator.validateReceipt(refreshIfEmpty: true) { [weak self] result in
                guard let self = self else { return }

                if let error = error {
                    self.callRestoreCompletionHandlers(.failure(error))
                    return
                }
                self.callRestoreCompletionHandlers(result.map { $0.value })
            }
        }
    }
}
