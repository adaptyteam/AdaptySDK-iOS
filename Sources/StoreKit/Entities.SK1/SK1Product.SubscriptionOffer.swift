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
           introductoryPrice != nil {
            false
        } else {
            true
        }
    }

    var introductoryOffer: AdaptySubscriptionOffer? {
        guard let offer = introductoryPrice else { return nil }
        return AdaptySubscriptionOffer(
            offerType: .introductory,
            offer: offer,
            locale: priceLocale
        )
    }

    func promotionalOffer(byIdentifier identifier: String) -> AdaptySubscriptionOffer? {
        guard let offer = discounts.first(where: { $0.identifier == identifier })
        else { return nil }
        return AdaptySubscriptionOffer(
            offerType: .promotional(identifier),
            offer: offer,
            locale: priceLocale
        )
    }
}

private extension AdaptySubscriptionOffer {
    init(
        offerType: OfferTypeWithIdentifier,
        offer: SK1Product.SubscriptionOffer,
        locale: Locale
    ) {
        let period = offer.subscriptionPeriod.asAdaptyProductSubscriptionPeriod
        self.init(
            _price: Price(
                amount: offer.price as Decimal,
                currencyCode: locale.unfCurrencyCode,
                currencySymbol: locale.currencySymbol,
                localizedString: locale.localized(sk1Price: offer.price)
            ),
            offerTypeWithIdentifier: offerType,
            subscriptionPeriod: period,
            numberOfPeriods: offer.numberOfPeriods,
            paymentMode: offer.paymentMode.asPaymentMode,
            localizedSubscriptionPeriod: locale.localized(period: period),
            localizedNumberOfPeriods: locale.localized(period: period, numberOfPeriods: offer.numberOfPeriods)
        )
    }
}
