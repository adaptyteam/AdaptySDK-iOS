//
//  StoreKit.Product.SubscriptionOffer.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 01.02.2024
//

import StoreKit

extension StoreKit.Product.SubscriptionOffer {
    var subscriptionOfferIdentifier: AdaptySubscriptionOffer.Identifier {
        .init(offerId: id, offerType: type.asAdaptySubscriptionOfferType)
    }

    fileprivate func asAdaptySubscriptionOffer(
        priceFormatStyle: Decimal.FormatStyle.Currency,
        subscriptionPeriodFormatStyle: Date.ComponentsFormatStyle
    ) -> AdaptySubscriptionOffer {
        let period = period.asAdaptySubscriptionPeriod
        let periodLocale = subscriptionPeriodFormatStyle.locale
        return .init(
            price: price,
            currencyCode: priceFormatStyle.currencyCode,
            localizedPrice: displayPrice,
            offerIdentifier: subscriptionOfferIdentifier,
            subscriptionPeriod: period,
            numberOfPeriods: periodCount,
            paymentMode: paymentMode.asAdaptySubscriptionOfferPaymentMode,
            localizedSubscriptionPeriod: periodLocale.localized(period: period),
            localizedNumberOfPeriods: periodLocale.localized(period: period, numberOfPeriods: periodCount)
        )
    }
}

extension StoreKit.Product {
    func adaptySubscriptionOffer(
        by offerIdentifier: AdaptySubscriptionOffer.Identifier,
        billingPlan: AdaptySubscriptionBillingPlan
    ) -> AdaptySubscriptionOffer? {
        guard let offer = subscription?.offer(by: offerIdentifier, for: billingPlan) else { return nil }
        return offer.asAdaptySubscriptionOffer(
            priceFormatStyle: priceFormatStyle,
            subscriptionPeriodFormatStyle: subscriptionPeriodFormatStyle
        )
    }

    func adaptySubscriptionOffer(by offer: SubscriptionOffer) -> AdaptySubscriptionOffer {
        offer.asAdaptySubscriptionOffer(
            priceFormatStyle: priceFormatStyle,
            subscriptionPeriodFormatStyle: subscriptionPeriodFormatStyle
        )
    }
}
