//
//  SK1Product.SubscriptionOffer.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 23.09.2024
//

import StoreKit

extension SK1Product {
    typealias SubscriptionOffer = SKProductDiscount
}

extension AdaptyProductDiscount {
    init(discount: SK1Product.SubscriptionOffer, locale: Locale) {
        let period = discount.subscriptionPeriod.asAdaptyProductSubscriptionPeriod

        self.init(
            _price: Price(
                amount: discount.price as Decimal,
                currencyCode: locale.unfCurrencyCode,
                currencySymbol: locale.currencySymbol,
                localizedString: locale.localized(sk1Price: discount.price)
            ),
            identifier: discount.identifier,
            offerType: discount.type.asOfferType,
            subscriptionPeriod: period,
            numberOfPeriods: discount.numberOfPeriods,
            paymentMode: discount.paymentMode.asPaymentMode,
            localizedSubscriptionPeriod: locale.localized(period: period),
            localizedNumberOfPeriods: locale.localized(period: period, numberOfPeriods: discount.numberOfPeriods)
        )
    }
}
