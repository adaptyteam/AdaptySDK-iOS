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
    private let session: Backend.MainExecutor

    private var lastTransactionCached: SK2Transaction?
    private var verifiedCurrentEntitlementsCached: (value: [SK2Transaction], at: Date)?
    private static let cacheDuration: TimeInterval = 60 * 5

    private var syncing: (task: AdaptyResultTask<VH<AdaptyProfile>?>, userId: AdaptyUserId)?

    init(session: Backend.MainExecutor) {
        self.session = session
    }

    func syncTransactions(for userId: AdaptyUserId) async throws(AdaptyError) -> VH<AdaptyProfile>? {
        let task: AdaptyResultTask<VH<AdaptyProfile>?>
        if let syncing, userId.isEqualProfileId(syncing.userId) {
            task = syncing.task
        } else {
            task = Task {
                defer { syncing = nil }
                do throws(HTTPError) {
                    guard let transaction = await getLastVerifiedTransaction()
                    else { return .success(nil) }

                    let value = try await session.syncTransaction(
                        userId: userId,
                        originalTransactionId: transaction.unfOriginalIdentifier
                    )
                    return .success(value)
                } catch {
                    return .failure(error.asAdaptyError)
                }
            }
            syncing = (task, userId)
        }
        return try await task.value.get()
    }

    private func getLastVerifiedTransaction() async -> SK2Transaction? {
        if let transaction = lastTransactionCached {
            return transaction
        } else if let transaction = await Self.fetchLastVerifiedTransaction() {
            lastTransactionCached = transaction
            return transaction
        } else {
            return nil
        }
    }

    private func getVerifiedCurrentEntitlements() async -> [SK2Transaction] {
        if let cache = verifiedCurrentEntitlementsCached,
           Date().timeIntervalSince(cache.at) < Self.cacheDuration
        {
            return cache.value
        }
        let transactions = await Self.fetchVerifiedCurrentEntitlements()

        verifiedCurrentEntitlementsCached = (transactions, at: Date())
        return transactions
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

    private static func fetchLastVerifiedTransaction() async -> SK2Transaction? {
        var lastTransaction: SK2Transaction?
        let stamp = Log.stamp

        await Adapty.trackSystemEvent(AdaptyAppleRequestParameters(methodName: .getAllSK2Transactions, stamp: stamp))
        log.verbose("call  SK2Transaction.all")

        for await transaction in SK2Transaction.all.compactMap(\.verifiedTransaction) {
            log.verbose("found transaction original-id: \(transaction.originalID), purchase date:\(transaction.purchaseDate)")

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
            log.warn("found unverified transaction original-id: \(transaction.originalID), purchase date:\(transaction.purchaseDate), environment: \(transaction.unfEnvironment)")
            return nil
        case let .verified(transaction):
            return transaction
        }
    }
}
