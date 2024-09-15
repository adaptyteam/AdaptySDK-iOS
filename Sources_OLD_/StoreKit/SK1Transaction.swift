//
//  SK1Transaction.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 20.10.2023
//

import StoreKit

typealias SK1Transaction = SKPaymentTransaction

extension SK1Transaction: AdaptyExtended {}

extension AdaptyExtension where Extended == SK1Transaction {
    var identifier: String? {
        this.transactionIdentifier
    }

    var originalIdentifier: String? {
        // https://developer.apple.com/documentation/appstoreserverapi/originaltransactionid
        this.original?.transactionIdentifier ?? this.transactionIdentifier
    }

    var logParams: EventParameters {
        [
            "product_id": this.payment.productIdentifier,
            "state": this.transactionState.stringValue,
            "transaction_id": identifier,
            "original_id": originalIdentifier,
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
