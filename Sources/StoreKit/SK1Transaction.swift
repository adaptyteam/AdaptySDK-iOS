//
//  SK1Transaction.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 20.10.2023
//  Copyright © 2023 Adapty. All rights reserved.
//

import StoreKit

typealias SK1Transaction = SKPaymentTransaction

extension SK1Transaction {
    var originalTransactionIdentifier: String? {
        // https://developer.apple.com/documentation/appstoreserverapi/originaltransactionid
        original?.transactionIdentifier ?? transactionIdentifier
    }

    var logParams: EventParameters {
        [
            "product_id": .value(payment.productIdentifier),
            "state": .value(transactionState.stringValue),
            "transaction_id": .valueOrNil(transactionIdentifier),
            "original_id": .valueOrNil(original?.transactionIdentifier),
        ]
    }
}

fileprivate extension SKPaymentTransactionState {
    var stringValue: String {
        switch self {
        case .purchasing: return "purchasing"
        case .purchased: return "purchased"
        case .failed: return "failed"
        case .restored: return "restored"
        case .deferred: return "deferred"
        default:
            return "unknown(\(self))"
        }
    }
}
