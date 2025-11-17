//
//  AdaptySK1Product.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 16.09.2024
//

import StoreKit

protocol AdaptySK1Product: AdaptyProduct {
    var skProduct: SK1Product { get }
}

extension AdaptySK1Product {
    public var sk1Product: SK1Product? { skProduct }

    public var sk2Product: SK2Product? { nil }

    public var vendorProductId: String { skProduct.productIdentifier }

    public var localizedDescription: String { skProduct.localizedDescription }

    public var localizedTitle: String { skProduct.localizedTitle }

    public var price: Decimal { skProduct.price as Decimal }

    public var priceLocale: Locale { skProduct.priceLocale }

    public var currencyCode: String? { skProduct.priceLocale.unfCurrencyCode }

    public var currencySymbol: String? { skProduct.priceLocale.currencySymbol }

    public var regionCode: String? { skProduct.priceLocale.unfRegionCode }

    public var isFamilyShareable: Bool { skProduct.unfIsFamilyShareable }

    public var subscriptionPeriod: AdaptySubscriptionPeriod? {
        skProduct.subscriptionPeriod?.asAdaptySubscriptionPeriod
    }

    public var subscriptionGroupIdentifier: String? { skProduct.subscriptionGroupIdentifier }

    public var localizedPrice: String? {
        skProduct.priceLocale.localized(sk1Price: skProduct.price)
    }

    public var localizedSubscriptionPeriod: String? {
        guard let period = subscriptionPeriod else { return nil }
        return skProduct.priceLocale.localized(period: period)
    }

    public var description: String {
        "(vendorProductId: \(vendorProductId), skProduct: \(skProduct))"
    }
}

struct SK1ProductWrapper: AdaptySK1Product {
    let skProduct: SK1Product
}

extension SK1Product {
    var asAdaptyProduct: AdaptySK1Product { SK1ProductWrapper(skProduct: self) }
}
