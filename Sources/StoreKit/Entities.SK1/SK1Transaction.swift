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
    var unfProductID: String { payment.productIdentifier }

    @inlinable
    var unfOfferId: String? { payment.paymentDiscount?.identifier }

    var logParams: EventParameters {
        [
            "product_id": unfProductID,
            "state": transactionState.stringValue,
            "transaction_id": unfIdentifier,
            "original_id": unfOriginalIdentifier,
        ]
    }
}

struct SK1TransactionWithIdentifier: Sendable {
    let underlay: SK1Transaction
    private let id: String

    init(_ underlay: SK1Transaction, id: String) {
        self.underlay = underlay
        self.id = id
    }

    @inlinable
    var unfIdentifier: String { underlay.unfIdentifier ?? id }

    @inlinable
    var unfOriginalIdentifier: String { underlay.unfOriginalIdentifier ?? unfIdentifier }

    @inlinable
    var unfProductID: String { underlay.unfProductID }

    @inlinable
    var unfOfferId: String? { underlay.unfOfferId }

    @inlinable
    var logParams: EventParameters { underlay.logParams }
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
