//
//  PurchasedSubscriptionOfferInfo.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 05.10.2026.
//

import Foundation
import StoreKit

struct PurchasedSubscriptionOfferInfo: Sendable {
    let id: String?
    let type: String

    let price: Decimal?
    let paymentMode: AdaptySubscriptionOffer.PaymentMode?
    let period: AdaptySubscriptionPeriod?
}

extension PurchasedSubscriptionOfferInfo {
    init?(
     billingPlan: AdaptySubscriptionBillingPlan,
     subscription: Product.SubscriptionInfo?,
     transaction: StoreKit.Transaction
    ) {
        if let offerIdentifier = transaction.subscriptionOfferIdentifier,
            let subscriptionOffer = subscription?.offer(by: offerIdentifier, for: billingPlan) {
            self.init(
                id: subscriptionOffer.id,
                type: subscriptionOffer.type.asAdaptySubscriptionOfferType.rawValue,
                price: subscriptionOffer.price,
                paymentMode: subscriptionOffer.paymentMode.asAdaptySubscriptionOfferPaymentMode,
                period: subscriptionOffer.period.asAdaptySubscriptionPeriod
            )
        } else if let offerType = transaction.unfOfferType{
            self.init(
                id: transaction.unfOfferId,
                type: offerType.asAdaptyTransactionOfferType.stringValue,
                price: nil,
                paymentMode: transaction.unfOfferPaymentMode,
                period: transaction.unfOfferPeriod
            )
        } else {
            return nil
        }
    }
}
