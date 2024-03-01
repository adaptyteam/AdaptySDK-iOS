//
//  SK1Transaction.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 20.10.2023
//  Copyright © 2023 Adapty. All rights reserved.
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
            "product_id": .value(this.payment.productIdentifier),
            "state": .value(this.transactionState.stringValue),
            "transaction_id": .valueOrNil(identifier),
            "original_id": .valueOrNil(originalIdentifier),
        ]
    }
}

private extension SKPaymentTransactionState {
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
