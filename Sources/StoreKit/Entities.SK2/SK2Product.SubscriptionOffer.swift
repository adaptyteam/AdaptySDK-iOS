//
//  SK2Product.SubscriptionOffer.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 01.02.2024
//

import StoreKit

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
extension AdaptyProductDiscount {
    init(
        offer: SK2Product.SubscriptionOffer,
        currencyCode: String?,
        priceLocale: Locale,
        periodLocale: Locale
    ) {
        let period = offer.period.asAdaptyProductSubscriptionPeriod

        self.init(
            _price: Price(
                amount: offer.price,
                currencyCode: currencyCode,
                currencySymbol: priceLocale.currencySymbol,
                localizedString: offer.displayPrice
            ),
            identifier: offer.id,
            offerType: offer.type.asOfferType,
            subscriptionPeriod: period,
            numberOfPeriods: offer.periodCount,
            paymentMode: offer.paymentMode.asPaymentMode,
            localizedSubscriptionPeriod: periodLocale.localized(period: period),
            localizedNumberOfPeriods: periodLocale.localized(period: period, numberOfPeriods: offer.periodCount)
        )
    }
}

