//
//  SKProductsManager+PurchasedSK1Transaction.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 01.06.2023
//

import StoreKit

extension SKProductsManager {
    func fillPurchasedTransaction(
        variationId: String?,
        persistentVariationId: String? = nil,
        purchasedSK1Transaction transaction: (value: SK1Transaction, id: String),
        _ completion: @escaping (PurchasedTransaction) -> Void
    ) {
        let productId = transaction.value.payment.productIdentifier

        fetchSK1Product(productIdentifier: productId, fetchPolicy: .returnCacheDataElseLoad) { result in
            if let error = result.error {
                Log.error("SK1QueueManager: fetch SK1Product \(productId) error: \(error)")
            }
            completion(PurchasedTransaction(
                sk1Product: try? result.get(),
                variationId: variationId,
                persistentVariationId: persistentVariationId,
                purchasedSK1Transaction: transaction
            ))
        }
    }
}

extension PurchasedTransaction {
    static func withSK1Product(
        _ sk1Product: SK1Product,
        _ variationId: String?,
        _ persistentVariationId: String?,
        purchasedSK1Transaction: (value: SK1Transaction, id: String)
    ) -> PurchasedTransaction {
        .init(
            sk1Product: sk1Product,
            variationId: variationId,
            persistentVariationId: persistentVariationId,
            purchasedSK1Transaction: purchasedSK1Transaction
        )
    }
}

private extension PurchasedTransaction {
    init(
        sk1Product: SK1Product?,
        variationId: String?,
        persistentVariationId: String?,
        purchasedSK1Transaction transaction: (value: SK1Transaction, id: String)
    ) {
        let (transaction, transactionIdentifier) = transaction
        let offer: PurchasedTransaction.SubscriptionOffer? =
            if let discountIdentifier = transaction.payment.paymentDiscount?.identifier {
                if let discount = sk1Product?.discounts.first(where: { $0.identifier == discountIdentifier }) {
                    PurchasedTransaction.SubscriptionOffer.promotional(discount)
                } else {
                    .init(id: discountIdentifier, type: .promotional)
                }
            } else if let discount = sk1Product?.introductoryPrice {
                PurchasedTransaction.SubscriptionOffer.introductory(discount)
            } else {
                nil
            }

        self.init(
            transactionId: transaction.ext.identifier ?? transactionIdentifier,
            originalTransactionId: transaction.ext.originalIdentifier ?? transactionIdentifier,
            vendorProductId: transaction.payment.productIdentifier,
            productVariationId: variationId,
            persistentProductVariationId: persistentVariationId,
            price: sk1Product?.price.decimalValue,
            priceLocale: sk1Product?.priceLocale.ext.currencyCode,
            storeCountry: sk1Product?.priceLocale.ext.regionCode,
            subscriptionOffer: offer,
            environment: nil
        )
    }
}

private extension PurchasedTransaction.SubscriptionOffer {
    static func promotional(_ discount: SKProductDiscount) -> PurchasedTransaction.SubscriptionOffer {
        .init(
            id: discount.identifier,
            period: AdaptyProductSubscriptionPeriod(subscriptionPeriod: discount.subscriptionPeriod),
            paymentMode: AdaptyProductDiscount.PaymentMode(mode: discount.paymentMode),
            type: .promotional,
            price: discount.price.decimalValue
        )
    }
}

private extension PurchasedTransaction.SubscriptionOffer {
    static func introductory(_ discount: SKProductDiscount) -> PurchasedTransaction.SubscriptionOffer {
        .init(
            id: nil,
            period: AdaptyProductSubscriptionPeriod(subscriptionPeriod: discount.subscriptionPeriod),
            paymentMode: AdaptyProductDiscount.PaymentMode(mode: discount.paymentMode),
            type: .introductory,
            price: discount.price.decimalValue
        )
    }
}
