//
//  SK2TransactionManager.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 06.02.2024
//

import StoreKit

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
internal final class SK2TransactionManager {
    private let queue: DispatchQueue
    private var syncTransactionsCompletionHandlers: [AdaptyResultCompletion<VH<AdaptyProfile>?>]?

    private let storage: ProfileIdentifierStorage
    private let session: HTTPSession

    internal init(queue: DispatchQueue, storage: ProfileIdentifierStorage, backend: Backend) {
        self.queue = queue
        session = backend.createHTTPSession(responseQueue: queue)
        self.storage = storage
    }

    internal func syncTransactions(_ completion: @escaping AdaptyResultCompletion<VH<AdaptyProfile>?>) {
        queue.async { [weak self] in
            guard let self else {
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
                guard let self else { return }
                self.queue.async {
                    switch result {
                    case let .failure(error):
                        completedSync(.failure(error))
                    case let .success(transaction):
                        guard let transaction else {
                            completedSync(.success(nil))
                            return
                        }
                        self.session.performSyncTransactionRequest(
                            profileId: self.storage.profileId,
                            originalTransactionId: transaction.ext.originalIdentifier
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

                Log.verbose("SK2TransactionManager: found transaction original-id: \(transaction.ext.originalIdentifier), purchase date:\(transaction.purchaseDate)")

                guard let lasted = lastTransaction,
                      transaction.purchaseDate < lasted.purchaseDate else {
                    lastTransaction = transaction
                    continue
                }
            }

            let params: EventParameters? =
                if let lastTransaction {
                    [
                        "original_transaction_id": .valueOrNil(lastTransaction.ext.originalIdentifier),
                        "transaction_id": .valueOrNil(lastTransaction.ext.identifier),
                        "purchase_date": .valueOrNil(lastTransaction.purchaseDate),
                    ]
                } else {
                    nil
                }

            Adapty.logSystemEvent(AdaptyAppleResponseParameters(methodName: logName, callId: stamp, params: params))

            completion(.success(lastTransaction))
        }
    }
}
