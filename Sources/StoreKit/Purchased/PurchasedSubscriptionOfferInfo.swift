//
//  PurchasedSubscriptionOfferInfo.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 08.09.2022.
//

import Foundation
import StoreKit

struct PurchasedSubscriptionOfferInfo {
    let id: String?
    let offerType: AdaptyTransactionOfferType
    let period: AdaptySubscriptionPeriod?
    let paymentMode: AdaptySubscriptionOffer.PaymentMode
    let price: Decimal?

    private init(
        id: String?,
        offerType: AdaptyTransactionOfferType,
        period: AdaptySubscriptionPeriod?,
        paymentMode: AdaptySubscriptionOffer.PaymentMode,
        price: Decimal?
    ) {
        self.id = id
        self.offerType = offerType
        self.period = period
        self.paymentMode = paymentMode
        self.price = price
    }
}

extension PurchasedSubscriptionOfferInfo {
    init?(
        transaction: StoreKit.Transaction,
        product: AdaptyProduct?
    ) {
        self.init(transaction: transaction, product: product?.skProduct)
    }

    init?(
        transaction: StoreKit.Transaction,
        product: StoreKit.Product?
    ) {
        guard let offerType = transaction.unfOfferType else { return nil }

        let subscriptionOffer = product?.subscriptionOffer(
            by: transaction.unfOfferId,
            for: offerType
        )

        guard #available(iOS 17.2, macOS 14.2, tvOS 17.2, watchOS 10.2, visionOS 1.1, *),
              let transactionOffer = transaction.offer
        else {
            self.init(
                id: transaction.unfOfferId,
                offerType: offerType,
                period: subscriptionOffer?.period.asAdaptySubscriptionPeriod,
                paymentMode: subscriptionOffer?.paymentMode.asPaymentMode ?? .unknown,
                price: subscriptionOffer?.price
            )
            return
        }

        let period: AdaptySubscriptionPeriod? =
            if #available(iOS 18.4, macOS 15.4, tvOS 18.4, watchOS 11.4, visionOS 2.4, *) {
                transactionOffer.period?.asAdaptySubscriptionPeriod ?? subscriptionOffer?.period.asAdaptySubscriptionPeriod
            } else {
                subscriptionOffer?.period.asAdaptySubscriptionPeriod
            }

        self.init(
            id: transaction.unfOfferId,
            offerType: offerType,
            period: period,
            paymentMode: transactionOffer.paymentMode?.asPaymentMode ?? .unknown,
            price: subscriptionOffer?.price
        )
    }
}
