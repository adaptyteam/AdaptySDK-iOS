//
//  SK2Product.SubscriptionOffer.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 01.02.2024
//

import StoreKit

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
extension SK2Product {
    var introductoryOfferNotApplicable: Bool {
        subscription?.introductoryOffer == nil
    }

    private var unfIntroductoryOffer: SK2Product.SubscriptionOffer? {
        subscription?.introductoryOffer
    }

    private func unfPromotionalOffer(byId identifier: String) -> SK2Product.SubscriptionOffer? {
        subscription?.promotionalOffers.first(where: { $0.id == identifier })
    }

    func unfWinBackOffer(byId identifier: String) -> SK2Product.SubscriptionOffer? {
        guard #available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *) else {
            return nil
        }

        return subscription?.winBackOffers.first { $0.id == identifier }
    }

    func subscriptionOffer(by offerIdentifier: AdaptySubscriptionOffer.Identifier) -> AdaptySubscriptionOffer? {
        let offer: SK2Product.SubscriptionOffer? =
            switch offerIdentifier {
            case .introductory:
                unfIntroductoryOffer
            case let .promotional(id):
                unfPromotionalOffer(byId: id)
            case let .winBack(id):
                unfWinBackOffer(byId: id)
            }
        guard let offer else { return nil }

        let period = offer.period.asAdaptySubscriptionPeriod
        let periodLocale = unfPeriodLocale
        return AdaptySubscriptionOffer(
            price: offer.price,
            currencyCode: unfCurrencyCode,
//            currencySymbol: unfPriceLocale.currencySymbol,
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
