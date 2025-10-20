//
//  SK1Product.SubscriptionOffer.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 23.09.2024
//

import StoreKit

extension SK1Product {
    typealias SubscriptionOffer = SKProductDiscount

    var introductoryOfferNotApplicable: Bool {
        if let period = subscriptionPeriod,
           period.numberOfUnits > 0,
           introductoryPrice != nil
        { false }
        else
        { true }
    }

    func sk1ProductSubscriptionOffer(by offerIdentifier: AdaptySubscriptionOffer.Identifier) -> SubscriptionOffer? {
        switch offerIdentifier {
        case .introductory:
            introductoryPrice
        case let .promotional(id):
            discounts.first(where: { $0.identifier == id })
        case .winBack: nil
        case .code: nil
        }
    }

    func subscriptionOffer(by offerIdentifier: AdaptySubscriptionOffer.Identifier) -> AdaptySubscriptionOffer? {
        guard let offer: SubscriptionOffer = sk1ProductSubscriptionOffer(by: offerIdentifier) else { return nil }

        let locale = priceLocale
        let period = offer.subscriptionPeriod.asAdaptySubscriptionPeriod
        return AdaptySubscriptionOffer(
            price: offer.price as Decimal,
            currencyCode: locale.unfCurrencyCode,
//            currencySymbol: locale.currencySymbol,
            localizedPrice: locale.localized(sk1Price: offer.price),
            offerIdentifier: offerIdentifier,
            subscriptionPeriod: period,
            numberOfPeriods: offer.numberOfPeriods,
            paymentMode: offer.paymentMode.asPaymentMode,
            localizedSubscriptionPeriod: locale.localized(period: period),
            localizedNumberOfPeriods: locale.localized(period: period, numberOfPeriods: offer.numberOfPeriods)
        )
    }
}

extension SK1Product.SubscriptionOffer {
    typealias OfferType = SKProductDiscount.`Type`
}
