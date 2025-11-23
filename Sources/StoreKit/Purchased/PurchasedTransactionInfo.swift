//
//  PurchasedTransactionInfo.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 08.09.2022.
//

import Foundation
import StoreKit

struct PurchasedTransactionInfo: Sendable {
    let transactionId: String
    let originalTransactionId: String
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
        self.transactionId = transaction.unfIdentifier
        self.originalTransactionId = transaction.unfOriginalIdentifier
        self.vendorProductId = transaction.unfProductId
        self.price = product?.price
        self.priceLocale = product?.priceLocale.unfCurrencyCode
        self.storeCountry = product?.priceLocale.unfRegionCode
        self.subscriptionOffer = .init(transaction: transaction, product: product)
        self.environment = transaction.unfEnvironment
    }
}
