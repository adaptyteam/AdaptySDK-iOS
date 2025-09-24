//
//  AdaptyUnfinishedTransaction.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 07.09.2025.
//
import StoreKit

private let log = Log.sk2TransactionManager

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
public struct AdaptyUnfinishedTransaction: Sendable {
    public let sk2SignedTransaction: VerificationResult<Transaction>

    public func finish() async throws(AdaptyError) {
        try await Adapty.withActivatedSDK(methodName: .manualFinishTransaction, logParams: [
            "transaction_id": sk2Transaction.unfIdentifier,
        ]) { sdk throws(AdaptyError) in
            guard !sdk.observerMode else { throw AdaptyError.notAllowedInObserveMode() }

            guard case let .verified(sk2Transaction) = sk2SignedTransaction else {
                return
            }

            await sdk.manualFinishTransaction(sk2Transaction)
        }
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
private extension Adapty {
    func manualFinishTransaction(_ sk2Transaction: SK2Transaction) async {
        let synced = await purchasePayloadStorage.isSyncedTransaction(sk2Transaction.unfIdentifier)
        await purchasePayloadStorage.removeUnfinishedTransaction(sk2Transaction.unfIdentifier)

        if !synced { return }

        await finish(transaction: sk2Transaction, recived: .manual)
        log.info("Finish unfinished transaction: \(sk2Transaction) for product: \(sk2Transaction.unfProductId) after manual call method (already synchronized)")
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
public extension AdaptyUnfinishedTransaction {
    var sk2Transaction: Transaction {
        sk2SignedTransaction.unsafePayloadValue
    }

    var jwsTransaction: String {
        sk2SignedTransaction.jwsRepresentation
    }
}
