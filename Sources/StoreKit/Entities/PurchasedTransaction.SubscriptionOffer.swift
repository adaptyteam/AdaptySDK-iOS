//
//  PurchasedTransaction.SubscriptionOffer.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 08.09.2022.
//

import Foundation

extension PurchasedTransaction {
    struct SubscriptionOffer: Sendable {
        let id: String?
        let period: AdaptySubscriptionPeriod?
        let paymentMode: AdaptySubscriptionOffer.PaymentMode
        let offerType: PurchasedTransaction.OfferType
        let price: Decimal?

        init(
            id: String,
            offerType: PurchasedTransaction.OfferType
        ) {
            self.id = id
            period = nil
            paymentMode = .unknown
            self.offerType = offerType
            price = nil
        }

        init(
            id: String?,
            period: AdaptySubscriptionPeriod?,
            paymentMode: AdaptySubscriptionOffer.PaymentMode,
            offerType: PurchasedTransaction.OfferType,
            price: Decimal?
        ) {
            self.id = id
            self.period = period
            self.paymentMode = paymentMode
            self.offerType = offerType
            self.price = price
        }
    }
}

extension PurchasedTransaction.SubscriptionOffer: Encodable {
    enum BackendCodingKeys: String, CodingKey {
        case periodUnit = "period_unit"
        case periodNumberOfUnits = "number_of_units"
        case paymentMode = "type"
        case offerType = "category"
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: BackendCodingKeys.self)
        try container.encode(paymentMode, forKey: .paymentMode)
        try container.encodeIfPresent(period?.unit, forKey: .periodUnit)
        try container.encodeIfPresent(period?.numberOfUnits, forKey: .periodNumberOfUnits)
        try container.encode(offerType, forKey: .offerType)
    }
}
