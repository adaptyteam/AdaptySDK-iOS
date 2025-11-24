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
    let price: Decimal?
    let priceLocale: String?
    let storeCountry: String?
    let subscriptionOffer: PurchasedSubscriptionOfferInfo?
    let environment: String

    init(
        product: AdaptyProduct?,
        transaction: StoreKit.Transaction
    ) {
        self.transactionId = transaction.id
        self.originalTransactionId = transaction.originalID
        self.vendorProductId = transaction.productID
        self.price = product?.price
        self.priceLocale = product?.priceLocale.unfCurrencyCode
        self.storeCountry = product?.priceLocale.unfRegionCode
        self.subscriptionOffer = .init(transaction: transaction, product: product)
        self.environment = transaction.unfEnvironment
    }
}
