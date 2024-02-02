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

    var environmentString: String? {
        guard #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, visionOS 1.0, *) else {
            return Optional(environmentStringRepresentation).flatMap { $0.isEmpty ? nil : $0.lowercased() }
        }

        switch environment {
        case .production: return "production"
        case .sandbox: return "sandbox"
        case .xcode: return "xcode"
        default: return environment.rawValue
        }
    }
}
