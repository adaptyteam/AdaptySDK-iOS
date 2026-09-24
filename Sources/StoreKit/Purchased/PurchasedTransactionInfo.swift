//
//  PurchasedTransactionInfo.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 08.09.2022.
//

import Foundation
import StoreKit

struct PurchasedTransactionInfo: Sendable {
    let transactionId: UInt64
    let originalTransactionId: UInt64
    let vendorProductId: String
    let billingPlan: AdaptySubscriptionBillingPlan?
    let environment: String

    init(
        transaction: StoreKit.Transaction
    ) {
        transactionId = transaction.id
        originalTransactionId = transaction.originalID
        vendorProductId = transaction.productID
        billingPlan = transaction.unfBillingPlan
        environment = transaction.unfEnvironment
    }
}
