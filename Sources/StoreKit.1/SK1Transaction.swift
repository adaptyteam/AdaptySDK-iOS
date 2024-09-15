//
//  SK1Transaction.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 20.10.2023
//

import StoreKit

typealias SK1Transaction = SKPaymentTransaction

extension SK1Transaction {
    var unfIdentifier: String? {
        transactionIdentifier
    }

    var unfOriginalIdentifier: String? {
        // https://developer.apple.com/documentation/appstoreserverapi/originaltransactionid
        original?.transactionIdentifier ?? transactionIdentifier
    }

    var logParams: EventParameters {
        [
            "product_id": payment.productIdentifier,
            "state": transactionState.stringValue,
            "transaction_id": unfIdentifier,
            "original_id": unfOriginalIdentifier,
        ]
    }
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
