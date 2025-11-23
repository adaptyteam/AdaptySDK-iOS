//
//  StoreKit.Product.SubscriptionOffer.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 01.02.2024
//

import StoreKit

extension StoreKit.Product {
    var introductoryOfferNotApplicable: Bool {
        subscription?.introductoryOffer == nil
    }

    func sk2ProductSubscriptionOffer(by offerIdentifier: AdaptySubscriptionOffer.Identifier) -> SubscriptionOffer? {
        switch offerIdentifier {
        case .introductory:
            subscription?.introductoryOffer
        case let .promotional(offerId):
            subscription?.promotionalOffers.first(where: { $0.id == offerId })
        case let .winBack(offerId):
            if #available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *) {
                subscription?.winBackOffers.first { $0.id == offerId }
            } else {
                nil
            }
        case .code:
            nil
        }
    }

    func subscriptionOffer(by offerIdentifier: AdaptySubscriptionOffer.Identifier) -> AdaptySubscriptionOffer? {
        guard let offer: SubscriptionOffer = sk2ProductSubscriptionOffer(by: offerIdentifier) else { return nil }

        let period = offer.period.asAdaptySubscriptionPeriod
        let periodLocale = subscriptionPeriodFormatStyle.locale
        return AdaptySubscriptionOffer(
            price: offer.price,
            currencyCode: priceFormatStyle.currencyCode,
//            currencySymbol: priceFormatStyle.locale.currencySymbol,
            localizedPrice: offer.displayPrice,
            offerIdentifier: offerIdentifier,
            subscriptionPeriod: period,
            numberOfPeriods: offer.periodCount,
            paymentMode: offer.paymentMode.asPaymentMode,
            localizedSubscriptionPeriod: periodLocale.localized(period: period),
            localizedNumberOfPeriods: periodLocale.localized(period: period, numberOfPeriods: offer.periodCount)
        )
    }
}
