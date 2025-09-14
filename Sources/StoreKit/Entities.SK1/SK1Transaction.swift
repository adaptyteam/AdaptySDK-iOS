//
//  SK1Transaction.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 20.10.2023
//

import StoreKit

typealias SK1Transaction = SKPaymentTransaction

extension SK1Transaction {
    @inlinable
    var unfIdentifier: String? { transactionIdentifier }

    @inlinable
    var unfOriginalIdentifier: String? {
        // https://developer.apple.com/documentation/appstoreserverapi/originaltransactionid
        original?.transactionIdentifier ?? transactionIdentifier
    }

    @inlinable
    var unfProductId: String { payment.productIdentifier }

    @inlinable
    var unfOfferId: String? { payment.paymentDiscount?.identifier }

    func logParams(other: EventParameters?) -> EventParameters {
        guard let other else { return logParams }
        return logParams.merging(other) { _, new in new }
    }

    var logParams: EventParameters {
        [
            "product_id": unfProductId,
            "state": transactionState.stringValue,
            "transaction_id": unfIdentifier,
            "original_id": unfOriginalIdentifier,
        ]
    }
}

struct SK1TransactionWithIdentifier: Sendable {
    let underlay: SK1Transaction
    private let id: String

    init?(_ underlay: SK1Transaction) {
        guard let id = underlay.transactionIdentifier else { return nil }
        self.underlay = underlay
        self.id = id
    }

    @inlinable
    var unfIdentifier: String { underlay.unfIdentifier ?? id }

    @inlinable
    var unfOriginalIdentifier: String { underlay.unfOriginalIdentifier ?? unfIdentifier }

    @inlinable
    var unfProductId: String { underlay.unfProductId }

    @inlinable
    var unfOfferId: String? { underlay.unfOfferId }

    @inlinable
    func logParams(other: EventParameters?) -> EventParameters { underlay.logParams(other: other) }

    @inlinable
    var logParams: EventParameters { underlay.logParams(other: nil) }
}

private extension SKPaymentTransactionState {
    var stringValue: String {
        switch self {
        case .purchasing: "purchasing"
        case .purchased: "purchased"
        case .failed: "failed"
        case .restored: "restored"
        case .deferred: "deferred"
        default:
            "unknown(\(self))"
        }
    }
}
