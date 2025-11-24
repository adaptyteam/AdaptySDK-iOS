//
//  TransactionManager.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 06.02.2024
//

import StoreKit

private let log = Log.transactionManager

actor TransactionManager {
    private let httpSession: Backend.MainExecutor
    private let storage: PurchasePayloadStorage

    private var lastTransactionOriginalIdentifier: UInt64?
    private var verifiedCurrentEntitlementsCached: (value: [StoreKit.Transaction], at: Date)?

    private static let cacheDuration: TimeInterval = 60 * 5

    private var syncingTransactionsHistory: (task: AdaptyResultTask<Void>, userId: AdaptyUserId)?
    private var syncingUnfinishedTransactions: AdaptyResultTask<Void>?

    init(
        httpSession: Backend.MainExecutor,
        storage: PurchasePayloadStorage
    ) {
        self.httpSession = httpSession
        self.storage = storage
    }

    func clearCache() {
        verifiedCurrentEntitlementsCached = nil
    }

    fileprivate func getLastTransactionOriginalIdentifier() async -> UInt64? {
        if let cached = lastTransactionOriginalIdentifier {
            return cached
        } else if let id = await TransactionManager.fetchLastVerifiedTransaction()?.originalID {
            lastTransactionOriginalIdentifier = id
            return id
        } else {
            return nil
        }
    }

    var hasUnfinishedTransactions: Bool {
        get async {
            await StoreKit.Transaction.unfinished.contains {
                if case .verified = $0 { true } else { false }
            }
        }
    }

    func getVerifiedCurrentEntitlements() async -> [StoreKit.Transaction] {
        if let cache = verifiedCurrentEntitlementsCached,
           Date().timeIntervalSince(cache.at) < Self.cacheDuration
        {
            return cache.value
        }
        let transactions = await Self.fetchVerifiedCurrentEntitlements()

        verifiedCurrentEntitlementsCached = (transactions, at: Date())
        return transactions
    }

    func syncTransactionHistory(for userId: AdaptyUserId) async throws(AdaptyError) {
        let task: AdaptyResultTask<Void>
        if let syncing = syncingTransactionsHistory, userId.isEqualProfileId(syncing.userId) {
            task = syncing.task
        } else {
            task = Task {
                defer { syncingTransactionsHistory = nil }
                guard let sdk = await Adapty.optionalSDK else { return .failure(AdaptyError.notActivated()) }
                return await sdk.sendLastTransactionOriginalId(manager: self, for: userId)
            }
            syncingTransactionsHistory = (task, userId)
        }
        try await task.value.get()
    }

    func syncUnfinishedTransactions() async throws(AdaptyError) {
        let task: AdaptyResultTask<Void>
        if let syncing = syncingUnfinishedTransactions {
            task = syncing
        } else {
            task = Task {
                defer { syncingUnfinishedTransactions = nil }
                guard let sdk = await Adapty.optionalSDK else { return .failure(AdaptyError.notActivated()) }
                return await sdk.sendUnfinishedTransactions(manager: self)
            }
            syncingUnfinishedTransactions = task
        }
        try await task.value.get()
    }
}

private extension Adapty {
    func sendLastTransactionOriginalId(manager: TransactionManager, for userId: AdaptyUserId) async -> AdaptyResult<Void> {
        guard let originalTransactionId = await manager.getLastTransactionOriginalIdentifier() else {
            return .success(())
        }

        do throws(HTTPError) {
            let response = try await httpSession.syncTransactionsHistory(
                originalTransactionId: originalTransactionId,
                for: userId
            )
            handleTransactionResponse(response)
            return .success(())
        } catch {
            return .failure(error.asAdaptyError)
        }
    }

    func sendUnfinishedTransactions(manager: TransactionManager) async -> AdaptyResult<Void> {
        guard !observerMode else { return .success(()) }
        let unfinishedTranasactions = await TransactionManager.fetchUnfinishedTransactions()
        guard !unfinishedTranasactions.isEmpty else { return .success(()) }
        for signedTransaction in unfinishedTranasactions {
            switch signedTransaction {
            case let .unverified(transaction, error):
                log.error("Unfinished transaction \(transaction.id) (originalId: \(transaction.originalID),  productId: \(transaction.productID)) is unverified. Error: \(error.localizedDescription)")
                await transaction.finish()
                log.warn("Finish unverified unfinished transaction: \(transaction) of product: \(transaction.productID) error: \(error.localizedDescription)")

                await purchasePayloadStorage.removePurchasePayload(forTransaction: transaction)
                await purchasePayloadStorage.removeUnfinishedTransaction(transaction.id)
                Adapty.trackSystemEvent(AdaptyAppleRequestParameters(
                    methodName: .finishTransaction,
                    params: transaction.logParams(other: ["unverified": error.localizedDescription])
                ))
            case let .verified(transaction):
                if await purchasePayloadStorage.isSyncedTransaction(transaction.id) { continue }

                guard !transaction.isXcodeEnvironment else {
                    log.verbose("Skip backend sync for Xcode environment transaction \(transaction.id)")
                    await attemptToFinish(transaction: transaction, logSource: "unfinished")
                    continue
                }

                do {
                    let productOrNil = try? await productsManager.fetchProduct(
                        id: transaction.productID,
                        fetchPolicy: .returnCacheDataElseLoad
                    ).asAdaptyProduct

                    try await report(
                        .init(
                            product: productOrNil,
                            transaction: transaction
                        ),
                        payload: purchasePayloadStorage.purchasePayload(
                            byTransaction: transaction,
                            orCreateFor: ProfileStorage.userId
                        ),
                        reason: .unfinished
                    )

                    await attemptToFinish(transaction: transaction, logSource: "unfinished")
                } catch {
                    log.error("Failed to validate unfinished transaction: \(transaction) for product: \(transaction.productID)")
                    return .failure(error)
                }
            }
        }
        return .success(())
    }
}

extension Adapty {
    func getUnfinishedTransactions() async throws(AdaptyError) -> [AdaptyUnfinishedTransaction] {
        let transactions = await TransactionManager.fetchUnfinishedTransactions()
        let ids = await purchasePayloadStorage.unfinishedTransactionIds()
        guard !ids.isEmpty, !transactions.isEmpty else { return [] }

        return transactions.compactMap {
            if ids.contains($0.unsafePayloadValue.id) {
                AdaptyUnfinishedTransaction(signedTransaction: $0)
            } else {
                nil
            }
        }
    }
}

private extension TransactionManager {
    static func fetchUnfinishedTransactions() async -> [VerificationResult<StoreKit.Transaction>] {
        let stamp = Log.stamp

        Adapty.trackSystemEvent(AdaptyAppleRequestParameters(methodName: .getUnfinishedTransactions, stamp: stamp))
        log.verbose("call  StoreKit.Transaction.unfinished")

        let signedTransactions = await StoreKit.Transaction.unfinished.reduce(into: []) { $0.append($1) }

        Adapty.trackSystemEvent(AdaptyAppleResponseParameters(methodName: .getUnfinishedTransactions, stamp: stamp, params: ["count": signedTransactions.count]))

        log.verbose("StoreKit.Transaction.unfinished.count = \(signedTransactions.count)")
        return signedTransactions
    }

    private static func fetchVerifiedCurrentEntitlements() async -> [StoreKit.Transaction] {
        let stamp = Log.stamp

        Adapty.trackSystemEvent(AdaptyAppleRequestParameters(methodName: .getCurrentEntitlements, stamp: stamp))
        log.verbose("call  StoreKit.Transaction.currentEntitlements")

        let signedTransactions = await StoreKit.Transaction.currentEntitlements.reduce(into: []) { $0.append($1) }
        let transactions: [StoreKit.Transaction] = signedTransactions.compactMap(\.verifiedTransaction)

        Adapty.trackSystemEvent(AdaptyAppleResponseParameters(methodName: .getCurrentEntitlements, stamp: stamp, params: ["total_count": signedTransactions.count, "verified_count": transactions.count]))

        let unfinishedConsumablesTransactions = await Self.fetchUnfinishedTransactions()
            .compactMap(\.verifiedTransaction)
            .filter { $0.productType == .consumable }

        log.verbose("StoreKit.Transaction.currentEntitlements total count: \(signedTransactions.count), verified count: \(transactions.count), unfinished consumables: \(unfinishedConsumablesTransactions.count)")

        return transactions + unfinishedConsumablesTransactions
    }

    static func fetchLastVerifiedTransaction() async -> StoreKit.Transaction? {
        var lastTransaction: StoreKit.Transaction?
        let stamp = Log.stamp

        Adapty.trackSystemEvent(AdaptyAppleRequestParameters(methodName: .getAllTransactions, stamp: stamp))
        log.verbose("call StoreKit.Transaction.all")

        for await transaction in StoreKit.Transaction.all.compactMap(\.verifiedTransaction) {
            log.verbose("found transaction originalId: \(transaction.originalID), purchase date:\(transaction.purchaseDate)")

            guard !transaction.isXcodeEnvironment else { continue }
            guard let lasted = lastTransaction,
                  transaction.purchaseDate < lasted.purchaseDate
            else {
                lastTransaction = transaction
                continue
            }
        }

        let params: EventParameters? =
            if let lastTransaction {
                [
                    "original_transaction_id": lastTransaction.originalID,
                    "transaction_id": lastTransaction.id,
                    "purchase_date": lastTransaction.purchaseDate,
                ]
            } else {
                nil
            }

        Adapty.trackSystemEvent(AdaptyAppleResponseParameters(methodName: .getAllTransactions, stamp: stamp, params: params))

        return lastTransaction
    }
}

private extension VerificationResult<StoreKit.Transaction> {
    var verifiedTransaction: StoreKit.Transaction? {
        switch self {
        case let .unverified(transaction, _):
            log.warn("found unverified transaction originalId: \(transaction.originalID), purchase date:\(transaction.purchaseDate), environment: \(transaction.unfEnvironment)")
            return nil
        case let .verified(transaction):
            return transaction
        }
    }
}
