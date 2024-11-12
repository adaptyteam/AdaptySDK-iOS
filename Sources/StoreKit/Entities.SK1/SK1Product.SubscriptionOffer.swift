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
        {
            false
        } else {
            true
        }
    }

    private var unfIntroductoryOffer: SK1Product.SubscriptionOffer? {
        introductoryPrice
    }

    private func unfPromotionalOffer(byId identifier: String) -> SK1Product.SubscriptionOffer? {
        discounts.first(where: { $0.identifier == identifier })
    }

    func subscriptionOffer(by offerTypeWithIdentifier: AdaptySubscriptionOffer.OfferTypeWithIdentifier) -> AdaptySubscriptionOffer? {
        let offer: SK1Product.SubscriptionOffer? =
            switch offerTypeWithIdentifier {
            case .introductory:
                unfIntroductoryOffer
            case .promotional(let id):
                unfPromotionalOffer(byId: id)
            default:
                nil
            }
        guard let offer else { return nil }

        let locale = priceLocale
        let period = offer.subscriptionPeriod.asAdaptySubscriptionPeriod
        return AdaptySubscriptionOffer(
            _price: Price(
                amount: offer.price as Decimal,
                currencyCode: locale.unfCurrencyCode,
                currencySymbol: locale.currencySymbol,
                localizedString: locale.localized(sk1Price: offer.price)
            ),
            offerTypeWithIdentifier: offerTypeWithIdentifier,
            subscriptionPeriod: period,
            numberOfPeriods: offer.numberOfPeriods,
            paymentMode: offer.paymentMode.asPaymentMode,
            localizedSubscriptionPeriod: locale.localized(period: period),
            localizedNumberOfPeriods: locale.localized(period: period, numberOfPeriods: offer.numberOfPeriods)
        )
    }
}
