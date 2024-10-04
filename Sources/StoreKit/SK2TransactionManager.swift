//
//  SK2TransactionManager.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 06.02.2024
//

import StoreKit

private let log = Log.Category(name: "SK2TransactionManager")

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
actor SK2TransactionManager {
    private let storage: ProfileIdentifierStorage
    private let session: Backend.MainExecutor

    private var lastTransactionCached: SK2Transaction?
    private var syncTaskCached: Task<VH<AdaptyProfile>?, any Error>?
    private var syncProfileId: String?

    init(storage: ProfileIdentifierStorage, backend: Backend) {
        session = backend.createMainExecutor()
        self.storage = storage
    }

    func syncTransactions() async throws -> VH<AdaptyProfile>? {
        let syncTask: Task<VH<AdaptyProfile>?, any Error>
        if let task = syncTaskCached, syncProfileId == nil || syncProfileId == storage.profileId {
            syncTask = task
        } else {
            self.syncProfileId = nil
            syncTask = Task<VH<AdaptyProfile>?, any Error> {
                try await syncLastTransaction()
            }
            self.syncTaskCached = syncTask
        }
        return try await syncTask.value
    }

    private func syncLastTransaction() async throws -> VH<AdaptyProfile>? {
        defer {
            self.syncTaskCached = nil
            self.syncProfileId = nil
        }

        let lastTransaction: SK2Transaction

        if let transaction = lastTransactionCached {
            lastTransaction = transaction
        } else if let transaction = await Self.lastTransaction {
            lastTransactionCached = transaction
            lastTransaction = transaction
        } else {
            return nil
        }

        syncProfileId = storage.profileId
        return try await session.syncTransaction(
            profileId: storage.profileId,
            originalTransactionId: lastTransaction.unfOriginalIdentifier
        )
    }

    private static var lastTransaction: SK2Transaction? {
        get async {
            var lastTransaction: SK2Transaction?
            let stamp = Log.stamp

            await Adapty.trackSystemEvent(AdaptyAppleRequestParameters(methodName: .getAllSK2Transactions, stamp: stamp))
            log.verbose("call  SK2Transaction.all")

            for await verificationResult in SK2Transaction.all {
                guard case let .verified(transaction) = verificationResult else {
                    continue
                }

                log.verbose("found transaction original-id: \(transaction.originalID), purchase date:\(transaction.purchaseDate)")

                guard let lasted = lastTransaction,
                      transaction.purchaseDate < lasted.purchaseDate else {
                    lastTransaction = transaction
                    continue
                }
            }

            let params: EventParameters? =
                if let lastTransaction {
                    [
                        "original_transaction_id": lastTransaction.unfOriginalIdentifier,
                        "transaction_id": lastTransaction.unfIdentifier,
                        "purchase_date": lastTransaction.purchaseDate,
                    ]
                } else {
                    nil
                }

            await Adapty.trackSystemEvent(AdaptyAppleResponseParameters(methodName: .getAllSK2Transactions, stamp: stamp, params: params))

            return lastTransaction
        }
    }
}
