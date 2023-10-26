//
//  SK2Transaction.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 20.10.2023
//  Copyright © 2023 Adapty. All rights reserved.
//

import StoreKit

@available(iOS 15.0, tvOS 15.0, watchOS 8.0, macOS 12.0, *)
typealias SK2Transaction = Transaction

@available(iOS 15.0, tvOS 15.0, watchOS 8.0, macOS 12.0, *)
extension SK2Transaction {
    var logParams: EventParameters {
        [
            "product_id": .value(productID),
            "transaction_is_upgraded": .value(isUpgraded),
            "transaction_id": .value(transactionIdentifier),
            "original_id": .value(originalTransactionIdentifier),
        ]
    }

    var transactionIdentifier: String {
        String(id)
    }

    var originalTransactionIdentifier: String {
        String(originalID)
    }
}
