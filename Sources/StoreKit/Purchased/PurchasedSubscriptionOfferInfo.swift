//
//  PurchasedSubscriptionOfferInfo.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 08.09.2022.
//

import Foundation

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
        transaction: SKTransaction,
        product: AdaptyProduct?
    ) {
        if let sk2Transaction = transaction as? SK2Transaction
        {
            self.init(sk2Transaction: sk2Transaction, product: product)
        } else if let sk1Transaction = transaction as? SK1TransactionWithIdentifier {
            self.init(sk1Transaction: sk1Transaction, product: product)
        } else {
            return nil
        }
    }

    private init?(
        sk1Transaction: SK1TransactionWithIdentifier,
        product: AdaptyProduct?
    ) {
        if let sk2Product = product?.sk2Product
        {
            self.init(sk1Transaction: sk1Transaction, sk2Product: sk2Product)
        } else if let sk1Product = product?.sk1Product {
            self.init(sk1Transaction: sk1Transaction, sk1Product: sk1Product)
        } else {
            self.init(sk1Transaction: sk1Transaction, sk1Product: nil)
        }
    }

    private init?(
        sk2Transaction: SK2Transaction,
        product: AdaptyProduct?
    ) {
        if let sk2Product = product?.sk2Product {
            self.init(sk2Transaction: sk2Transaction, sk2Product: sk2Product)
        } else if let sk1Product = product?.sk1Product {
            self.init(sk2Transaction: sk2Transaction, sk1Product: sk1Product)
        } else {
            self.init(sk2Transaction: sk2Transaction, sk1Product: nil)
        }
    }

    private init?(
        sk1Transaction: SK1TransactionWithIdentifier,
        sk1Product: SK1Product?
    ) {
        let offerIdentifier: AdaptySubscriptionOffer.Identifier
        let sk1ProductOffer: SK1Product.SubscriptionOffer

        if let offerId = sk1Transaction.unfOfferId {
            offerIdentifier = .promotional(offerId)
            guard let value = sk1Product?.sk1ProductSubscriptionOffer(by: offerIdentifier) else {
                self.init(identifier: offerIdentifier)
                return
            }
            sk1ProductOffer = value
        } else {
            offerIdentifier = .introductory
            guard let value = sk1Product?.sk1ProductSubscriptionOffer(by: offerIdentifier) else {
                return nil
            }
            sk1ProductOffer = value
        }

        self.init(
            identifier: offerIdentifier,
            period: sk1ProductOffer.subscriptionPeriod.asAdaptySubscriptionPeriod,
            paymentMode: sk1ProductOffer.paymentMode.asPaymentMode,
            price: sk1ProductOffer.price.decimalValue
        )
    }

    private init?(
        sk1Transaction: SK1TransactionWithIdentifier,
        sk2Product: SK2Product?
    ) {
        let offerIdentifier: AdaptySubscriptionOffer.Identifier
        let sk2ProductOffer: SK2Product.SubscriptionOffer

        if let offerId = sk1Transaction.unfOfferId {
            offerIdentifier = .promotional(offerId)
            guard let value = sk2Product?.sk2ProductSubscriptionOffer(by: offerIdentifier) else {
                self.init(identifier: offerIdentifier)
                return
            }
            sk2ProductOffer = value
        } else {
            offerIdentifier = .introductory
            guard let value = sk2Product?.sk2ProductSubscriptionOffer(by: offerIdentifier) else {
                return nil
            }
            sk2ProductOffer = value
        }

        self.init(
            identifier: offerIdentifier,
            period: sk2ProductOffer.period.asAdaptySubscriptionPeriod,
            paymentMode: sk2ProductOffer.paymentMode.asPaymentMode,
            price: sk2ProductOffer.price
        )
    }

    private init?(
        sk2Transaction: SK2Transaction,
        sk1Product: SK1Product?
    ) {
        guard let offerIdentifier = sk2Transaction.subscriptionOfferIdentifier else { return nil }
        let sk1ProductOffer = sk1Product?.sk1ProductSubscriptionOffer(by: offerIdentifier)
        self.init(
            identifier: offerIdentifier,
            period: sk1ProductOffer?.subscriptionPeriod.asAdaptySubscriptionPeriod,
            paymentMode: sk1ProductOffer?.paymentMode.asPaymentMode ?? .unknown,
            price: sk1ProductOffer?.price.decimalValue,
            for: sk2Transaction
        )
    }

    init?(
        sk2Transaction: SK2Transaction,
        sk2Product: SK2Product?
    ) {
        guard let offerIdentifier = sk2Transaction.subscriptionOfferIdentifier else { return nil }
        let sk2ProductOffer = sk2Product?.sk2ProductSubscriptionOffer(by: offerIdentifier)
        self.init(
            identifier: offerIdentifier,
            period: sk2ProductOffer?.period.asAdaptySubscriptionPeriod,
            paymentMode: sk2ProductOffer?.paymentMode.asPaymentMode ?? .unknown,
            price: sk2ProductOffer?.price,
            for: sk2Transaction
        )
    }

    private init?(
        identifier: AdaptySubscriptionOffer.Identifier,
        period: AdaptySubscriptionPeriod?,
        paymentMode: AdaptySubscriptionOffer.PaymentMode,
        price: Decimal?,
        for sk2Transaction: SK2Transaction
    ) {
        if #available(iOS 17.2, macOS 14.2, tvOS 17.2, watchOS 10.2, visionOS 1.1, *),
           let offer = sk2Transaction.offer
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
        for sk2TransactionOffer: SK2Transaction.Offer
    ) {
        var period: AdaptySubscriptionPeriod?

        #if compiler(>=6.1)
        if #available(iOS 18.4, macOS 15.4, tvOS 18.4, watchOS 11.4, visionOS 2.4, *) {
            period = sk2TransactionOffer.period?.asAdaptySubscriptionPeriod
        }
        #else
        period = productOfferPeriod
        #endif

        self.init(
            identifier: sk2TransactionOffer.subscriptionOfferIdentifier ?? identifier,
            period: period ?? productOfferPeriod,
            paymentMode: sk2TransactionOffer.paymentMode?.asPaymentMode ?? .unknown,
            price: price
        )
    }
}
