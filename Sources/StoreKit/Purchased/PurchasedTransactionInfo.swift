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
        transactionId = transaction.id
        originalTransactionId = transaction.originalID
        vendorProductId = transaction.productID
        price = product?.price
        priceLocale = product?.priceLocale.unfCurrencyCode
        storeCountry = product?.priceLocale.unfRegionCode
        subscriptionOffer = .init(transaction: transaction, product: product)
        environment = transaction.unfEnvironment
    }
}
