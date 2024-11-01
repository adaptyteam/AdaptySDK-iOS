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

    var introductoryOffer: AdaptySubscriptionOffer? {
        guard let offer = subscription?.introductoryOffer else { return nil }
        return AdaptySubscriptionOffer(
            offerType: .introductory,
            offer: offer,
            product: self
        )
    }

    func promotionalOffer(byIdentifier identifier: String) -> AdaptySubscriptionOffer? {
        guard let offer = subscription?.promotionalOffers.first(where: { $0.id == identifier })
        else { return nil }
        return AdaptySubscriptionOffer(
            offerType: .promotional(identifier),
            offer: offer,
            product: self
        )
    }

    func winBackOffer(byIdentifier identifier: String) -> AdaptySubscriptionOffer? {
        guard let offer = unfWinBackOffer(byId: identifier) else { return nil }
        return AdaptySubscriptionOffer(
            offerType: .winBack(identifier),
            offer: offer,
            product: self
        )
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
private extension AdaptySubscriptionOffer {
    init(
        offerType: OfferTypeWithIdentifier,
        offer: SK2Product.SubscriptionOffer,
        product: SK2Product
    ) {
        let period = offer.period.asAdaptyProductSubscriptionPeriod
        let periodLocale = product.unfPeriodLocale
        self.init(
            _price: Price(
                amount: offer.price,
                currencyCode: product.unfCurrencyCode,
                currencySymbol: product.unfPriceLocale.currencySymbol,
                localizedString: offer.displayPrice
            ),
            offerTypeWithIdentifier: offerType,
            subscriptionPeriod: period,
            numberOfPeriods: offer.periodCount,
            paymentMode: offer.paymentMode.asPaymentMode,
            localizedSubscriptionPeriod: periodLocale.localized(period: period),
            localizedNumberOfPeriods: periodLocale.localized(period: period, numberOfPeriods: offer.periodCount)
        )
    }
}
