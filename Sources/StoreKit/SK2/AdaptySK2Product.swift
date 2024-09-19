//
//  AdaptySK2Product.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 16.09.2024
//

import StoreKit

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
struct AdaptySK2Product: AdaptyProduct {
    let skProduct: SK2Product

    var sk1Product: SK1Product? { nil }

    var sk2Product: SK2Product? { skProduct }

    var vendorProductId: String { skProduct.id }

    var localizedDescription: String { skProduct.description }

    var localizedTitle: String { skProduct.displayName }

    var price: Decimal { skProduct.price }

    var currencyCode: String? { skProduct.unfCurrencyCode }

    var currencySymbol: String? { skProduct.unfPriceLocale.currencySymbol }

    var regionCode: String? { skProduct.unfPriceLocale.unfRegionCode }

    var isFamilyShareable: Bool { skProduct.isFamilyShareable }

    var subscriptionPeriod: AdaptyProductSubscriptionPeriod? {
        guard let period = skProduct.subscription?.subscriptionPeriod else { return nil }
        return AdaptyProductSubscriptionPeriod(subscriptionPeriod: period)
    }

    var introductoryDiscount: AdaptyProductDiscount? {
        guard let offer = skProduct.subscription?.introductoryOffer else { return nil }
        return AdaptyProductDiscount(
            offer: offer,
            currencyCode: skProduct.unfCurrencyCode,
            priceLocale: skProduct.unfPriceLocale,
            periodLocale: skProduct.unfPeriodLocale
        )
    }

    var subscriptionGroupIdentifier: String? {
        skProduct.subscription?.subscriptionGroupID
    }

    var discounts: [AdaptyProductDiscount] {
        guard let offers = skProduct.subscription?.promotionalOffers, !offers.isEmpty else {
            return []
        }
        let code = skProduct.unfCurrencyCode
        let priceLocale = skProduct.unfPriceLocale
        let periodLocale = skProduct.unfPeriodLocale
        return offers.map { offer in
            AdaptyProductDiscount(
                offer: offer,
                currencyCode: code,
                priceLocale: priceLocale,
                periodLocale: periodLocale
            )
        }
    }

    func discount(byIdentifier identifier: String) -> AdaptyProductDiscount? {
        guard let offer = skProduct.subscription?.promotionalOffers.first(where: { $0.id == identifier })
        else { return nil }
        return AdaptyProductDiscount(
            offer: offer,
            currencyCode: skProduct.unfCurrencyCode,
            priceLocale: skProduct.unfPriceLocale,
            periodLocale: skProduct.unfPeriodLocale
        )
    }

    var localizedPrice: String? {
        skProduct.displayPrice
    }

    var localizedSubscriptionPeriod: String? {
        guard let period = subscriptionPeriod else { return nil }
        return skProduct.unfPeriodLocale.localized(period: period)
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
extension AdaptySK2Product: CustomStringConvertible {
    var description: String {
        "(vendorProductId: \(vendorProductId), skProduct: \(skProduct))"
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
extension SK2Product {
    var asAdaptyProduct: AdaptySK2Product { .init(skProduct: self) }
}
