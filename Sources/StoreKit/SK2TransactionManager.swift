//
//  SK2TransactionManager.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 06.02.2024
//

import StoreKit

private let log = Log.sk2TransactionManager

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
actor SK2TransactionManager {
    private let httpSession: Backend.MainExecutor
    private let storage: PurchasePayloadStorage

    private var lastTransactionOriginalIdentifier: String?
    private var verifiedCurrentEntitlementsCached: (value: [SK2Transaction], at: Date)?

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

    fileprivate func getLastTransactionOriginalIdentifier() async -> String? {
        if let cached = lastTransactionOriginalIdentifier {
            return cached
        } else if let id = await SK2TransactionManager.fetchLastVerifiedTransaction()?.unfOriginalIdentifier {
            lastTransactionOriginalIdentifier = id
            return id
        } else {
            return nil
        }
    }

    var hasUnfinishedTransactions: Bool {
        get async {
            await SK2Transaction.unfinished.contains {
                if case .verified = $0 { true } else { false }
            }
        }
    }

    func getVerifiedCurrentEntitlements() async -> [SK2Transaction] {
        if let cache = verifiedCurrentEntitlementsCached,
           Date().timeIntervalSince(cache.at) < Self.cacheDuration
        {
            return cache.value
        }
        let transactions = await Self.fetchVerifiedCurrentEntitlements()

        verifiedCurrentEntitlementsCached = (transactions, at: Date())
        return transactions
    }

    fileprivate func getUnfinishedTransactions() async -> [SK2SignedTransaction] {
        await Self.fetchUnfinishedTrunsactions()
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

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
private extension Adapty {
    func sendLastTransactionOriginalId(manager: SK2TransactionManager, for userId: AdaptyUserId) async -> AdaptyResult<Void> {
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

    func sendUnfinishedTransactions(manager: SK2TransactionManager) async -> AdaptyResult<Void> {
        guard !observerMode else { return .success(()) }
        while true {
            let unfinishedTranasactions = await manager.getUnfinishedTransactions()
            guard !unfinishedTranasactions.isEmpty else { return .success(()) }
            for sk2SignedTransaction in unfinishedTranasactions {
                switch sk2SignedTransaction {
                case let .unverified(sk2Transaction, error):
                    log.error("Unfinished transaction \(sk2Transaction.unfIdentifier) (originalId: \(sk2Transaction.unfOriginalIdentifier),  productId: \(sk2Transaction.unfProductId)) is unverified. Error: \(error.localizedDescription)")
                    await sk2Transaction.finish()
                    await purchasePayloadStorage.removePurchasePayload(forTransaction: sk2Transaction)
                    await purchasePayloadStorage.removeUnfinishedTransaction(sk2Transaction.id)
                    Adapty.trackSystemEvent(AdaptyAppleRequestParameters(
                        methodName: .finishTransaction,
                        params: sk2Transaction.logParams(other: ["unverified": error.localizedDescription])
                    ))
                case let .verified(sk2Transaction):
                    if await purchasePayloadStorage.isSyncedTransaction(sk2Transaction.id) { continue }

                    let productOrNil = try? await productsManager.fetchProduct(
                        id: sk2Transaction.unfProductId,
                        fetchPolicy: .returnCacheDataElseLoad
                    )

                    do {
                        try await report(
                            .init(
                                product: productOrNil,
                                transaction: sk2Transaction
                            ),
                            payload: purchasePayloadStorage.purchasePayload(
                                byTransaction: sk2Transaction,
                                orCreateFor: ProfileStorage.userId
                            ),
                            reason: .unfinished
                        )

                        guard await purchasePayloadStorage.canFinishSyncedTransaction(sk2Transaction.id) else {
                            log.info("Unfinished transaction synced: \(sk2Transaction), manual finish required for product: \(sk2Transaction.unfProductId)")
                            continue
                        }
                        
                        await finish(transaction: sk2Transaction, recived: .unfinished)
                        
                        log.info("Unfinished transaction synced: \(sk2Transaction) for product: \(sk2Transaction.unfProductId)")
                    } catch {
                        log.error("Failed to validate unfinished transaction: \(sk2Transaction) for product: \(sk2Transaction.unfProductId)")
                        return .failure(error)
                    }
                }
            }
        }
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
extension SK2TransactionManager {
    private static func fetchUnfinishedTrunsactions() async -> [SK2SignedTransaction] {
        let stamp = Log.stamp

        await Adapty.trackSystemEvent(AdaptyAppleRequestParameters(methodName: .getUnfinishedSK2Transactions, stamp: stamp))
        log.verbose("call  SK2Transaction.unfinished")

        let signedTransactions = await SK2Transaction.unfinished.reduce(into: []) { $0.append($1) }

        await Adapty.trackSystemEvent(AdaptyAppleResponseParameters(methodName: .getUnfinishedSK2Transactions, stamp: stamp, params: ["count": signedTransactions.count]))

        log.verbose("SK2Transaction.unfinished.count = \(signedTransactions.count)")
        return signedTransactions
    }

    private static func fetchVerifiedCurrentEntitlements() async -> [SK2Transaction] {
        let stamp = Log.stamp

        await Adapty.trackSystemEvent(AdaptyAppleRequestParameters(methodName: .getSK2CurrentEntitlements, stamp: stamp))
        log.verbose("call  SK2Transaction.currentEntitlements")

        let signedTransactions = await SK2Transaction.currentEntitlements.reduce(into: []) { $0.append($1) }
        let transaction: [SK2Transaction] = signedTransactions.compactMap(\.verifiedTransaction)

        await Adapty.trackSystemEvent(AdaptyAppleResponseParameters(methodName: .getSK2CurrentEntitlements, stamp: stamp, params: ["total_count": signedTransactions.count, "verified_count": transaction.count]))

        log.verbose("SK2Transaction.currentEntitlements total count: \(signedTransactions.count), verified count: \(transaction.count)")
        return transaction
    }

    fileprivate static func fetchLastVerifiedTransaction() async -> SK2Transaction? {
        var lastTransaction: SK2Transaction?
        let stamp = Log.stamp

        await Adapty.trackSystemEvent(AdaptyAppleRequestParameters(methodName: .getAllSK2Transactions, stamp: stamp))
        log.verbose("call  SK2Transaction.all")

        for await transaction in SK2Transaction.all.compactMap(\.verifiedTransaction) {
            log.verbose("found transaction originalId: \(transaction.unfOriginalIdentifier), purchase date:\(transaction.purchaseDate)")

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

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
extension SK2SignedTransaction {
    var verifiedTransaction: SK2Transaction? {
        switch self {
        case let .unverified(transaction, _):
            log.warn("found unverified transaction originalId: \(transaction.unfOriginalIdentifier), purchase date:\(transaction.purchaseDate), environment: \(transaction.unfEnvironment)")
            return nil
        case let .verified(transaction):
            return transaction
        }
    }
}
