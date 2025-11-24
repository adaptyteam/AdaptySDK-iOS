//
//  PurchasedSubscriptionOfferInfo.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 08.09.2022.
//

import Foundation
import StoreKit

struct PurchasedSubscriptionOfferInfo: Sendable {
    let id: String?
    let period: AdaptySubscriptionPeriod?
    let paymentMode: AdaptySubscriptionOffer.PaymentMode
    let offerType: AdaptySubscriptionOfferType
    let price: Decimal?

    fileprivate init(
        identifier: AdaptySubscriptionOffer.Identifier,
        period: AdaptySubscriptionPeriod? = nil,
        paymentMode: AdaptySubscriptionOffer.PaymentMode = .unknown,
        price: Decimal? = nil
    ) {
        self.id = identifier.offerId
        self.period = period
        self.paymentMode = paymentMode
        self.offerType = identifier.offerType
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
        guard let offerIdentifier = transaction.subscriptionOfferIdentifier else { return nil }
        let subscriptionOffer = product?.subscriptionOffer(by: offerIdentifier)
        self.init(
            identifier: offerIdentifier,
            period: subscriptionOffer?.period.asAdaptySubscriptionPeriod,
            paymentMode: subscriptionOffer?.paymentMode.asPaymentMode ?? .unknown,
            price: subscriptionOffer?.price,
            for: transaction
        )
    }

    private init?(
        identifier: AdaptySubscriptionOffer.Identifier,
        period: AdaptySubscriptionPeriod?,
        paymentMode: AdaptySubscriptionOffer.PaymentMode,
        price: Decimal?,
        for transaction: StoreKit.Transaction
    ) {
        if #available(iOS 17.2, macOS 14.2, tvOS 17.2, watchOS 10.2, visionOS 1.1, *),
           let offer = transaction.offer
        {
            self.init(
                identifier: identifier,
                productOfferPeriod: period,
                price: price,
                for: offer
            )
        } else {
            self.init(
                identifier: identifier,
                period: period,
                paymentMode: paymentMode,
                price: price
            )
        }
    }

    @available(iOS 17.2, macOS 14.2, tvOS 17.2, watchOS 10.2, visionOS 1.1, *)
    private init?(
        identifier: AdaptySubscriptionOffer.Identifier,
        productOfferPeriod: AdaptySubscriptionPeriod?,
        price: Decimal?,
        for transactionOffer: StoreKit.Transaction.Offer
    ) {
        var period: AdaptySubscriptionPeriod?

        #if compiler(>=6.1)
        if #available(iOS 18.4, macOS 15.4, tvOS 18.4, watchOS 11.4, visionOS 2.4, *) {
            period = transactionOffer.period?.asAdaptySubscriptionPeriod
        }
        #else
        period = productOfferPeriod
        #endif

        self.init(
            identifier: transactionOffer.subscriptionOfferIdentifier ?? identifier,
            period: period ?? productOfferPeriod,
            paymentMode: transactionOffer.paymentMode?.asPaymentMode ?? .unknown,
            price: price
        )
    }
}
