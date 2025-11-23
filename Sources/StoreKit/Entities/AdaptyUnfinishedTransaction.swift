//
//  AdaptyUnfinishedTransaction.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 07.09.2025.
//
import StoreKit

private let log = Log.transactionManager

public struct AdaptyUnfinishedTransaction: Sendable {
    public let signedTransaction: VerificationResult<Transaction>

    public func finish() async throws(AdaptyError) {
        try await Adapty.withActivatedSDK(methodName: .manualFinishTransaction, logParams: [
            "transaction_id": transaction.unfIdentifier,
        ]) { sdk throws(AdaptyError) in
            guard !sdk.observerMode else { throw AdaptyError.notAllowedInObserveMode() }

            guard case let .verified(transaction) = signedTransaction else {
                return
            }

            await sdk.manualFinishTransaction(transaction)
        }
    }
}

private extension Adapty {
    func manualFinishTransaction(_ transaction: StoreKit.Transaction) async {
        let synced = await purchasePayloadStorage.isSyncedTransaction(transaction.unfIdentifier)
        await purchasePayloadStorage.removeUnfinishedTransaction(transaction.unfIdentifier)

        if !synced { return }

        await finish(transaction: transaction)
        log.info("Finish unfinished transaction: \(transaction) for product: \(transaction.unfProductId) after manual call method (already synchronized)")
    }
}

public extension AdaptyUnfinishedTransaction {
    var transaction: Transaction {
        signedTransaction.unsafePayloadValue
    }

    var jwsTransaction: String {
        signedTransaction.jwsRepresentation
    }
}
