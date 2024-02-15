//
//  SK2TransactionManager.swift
//  Adapty
//
//  Created by Aleksei Valiano on 06.02.2024
//

import StoreKit

@available(iOS 15.0, tvOS 15.0, watchOS 8.0, macOS 12.0, *)
internal final class SK2TransactionManager {
    private let queue: DispatchQueue
    private var syncTransactionsCompletionHandlers: [AdaptyResultCompletion<VH<AdaptyProfile>?>]?

    private let storage: ProfileStorage
    private let session: HTTPSession

    internal init(queue: DispatchQueue, storage: ProfileStorage, backend: Backend) {
        self.queue = queue
        session = backend.createHTTPSession(responseQueue: queue)
        self.storage = storage
    }

    internal func syncTransactions(_ completion: @escaping AdaptyResultCompletion<VH<AdaptyProfile>?>) {
        queue.async { [weak self] in
            guard let self = self else {
                completion(.failure(SKManagerError.interrupted().asAdaptyError))
                return
            }

            if let handlers = self.syncTransactionsCompletionHandlers {
                self.syncTransactionsCompletionHandlers = handlers + [completion]
                Log.debug("SK2TransactionManager: Add handler to syncTransactionsCompletionHandlers.count = \(self.syncTransactionsCompletionHandlers?.count ?? 0)")

                return
            }
            self.syncTransactionsCompletionHandlers = [completion]

            Log.debug("SK2TransactionManager: Start validateReceipt syncTransactionsCompletionHandlers.count = \(self.syncTransactionsCompletionHandlers?.count ?? 0)")

            self.getSK2Transaction { [weak self] result in
                guard let self = self else { return }
                self.queue.async {
                    switch result {
                    case let .failure(error):
                        completedSync(.failure(error))
                    case let .success(transaction):
                        guard let transaction = transaction else {
                            completedSync(.success(nil))
                            return
                        }
                        self.session.performSyncTransactionRequest(
                            profileId: self.storage.profileId,
                            originalTransactionId: transaction.originalTransactionIdentifier
                        ) { result in
                            completedSync(result.map { $0 })
                        }
                    }
                }
            }
        }

        func completedSync(_ result: AdaptyResult<VH<AdaptyProfile>?>) {
            guard let handlers = syncTransactionsCompletionHandlers, !handlers.isEmpty else {
                Log.error("SK2TransactionManager: Not found syncTransactionsCompletionHandlers")
                return
            }
            syncTransactionsCompletionHandlers = nil
            Log.debug("SK2TransactionManager: Call syncTransactionsCompletionHandlers.count = \(handlers.count) with result = \(result)")

            handlers.forEach { $0(result) }
        }
    }

    private func getSK2Transaction(_ completion: @escaping AdaptyResultCompletion<SK2Transaction?>) {
        Task(priority: .medium) {
            var lastTransaction: Transaction?
            let logName = "get_all_transactions"
            let stamp = Log.stamp
            Adapty.logSystemEvent(AdaptyAppleRequestParameters(methodName: logName, callId: stamp))
            Log.verbose("SK2TransactionManager: call  SK2Transaction.all")

            for await verificationResult in SK2Transaction.all {
                guard case let .verified(transaction) = verificationResult else {
                    continue
                }

                Log.verbose("SK2TransactionManager: found transaction original-id: \(transaction.originalTransactionIdentifier), purchase date:\(transaction.purchaseDate)")

                guard let lasted = lastTransaction,
                      transaction.purchaseDate < lasted.purchaseDate else {
                    lastTransaction = transaction
                    continue
                }
            }

            let params: EventParameters?

            if let lastTransaction = lastTransaction {
                params = [
                    "original_transaction_id": .valueOrNil(lastTransaction.originalTransactionIdentifier),
                    "transaction_id": .valueOrNil(lastTransaction.transactionIdentifier),
                    "purchase_date": .valueOrNil(lastTransaction.purchaseDate),
                ]
            } else {
                params = nil
            }

            Adapty.logSystemEvent(AdaptyAppleResponseParameters(methodName: logName, callId: stamp, params: params))

            completion(.success(lastTransaction))
        }
    }
}