//
//  AdaptySK2Product.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 16.09.2024
//

import StoreKit

protocol AdaptySK2Product: AdaptyProduct {
    var skProduct: StoreKit.Product { get }
}

extension AdaptySK2Product {
    public var sk2Product: StoreKit.Product? { skProduct }

    public var vendorProductId: String { skProduct.id }

    public var localizedDescription: String { skProduct.description }

    public var localizedTitle: String { skProduct.displayName }

    public var price: Decimal { skProduct.price }

    public var priceLocale: Locale { skProduct.priceFormatStyle.locale  }

    public var currencyCode: String? { skProduct.priceFormatStyle.currencyCode }

    public var currencySymbol: String? { skProduct.priceFormatStyle.locale.currencySymbol }

    public var regionCode: String? { skProduct.priceFormatStyle.locale.unfRegionCode }

    public var isFamilyShareable: Bool { skProduct.isFamilyShareable }

    public var subscriptionPeriod: AdaptySubscriptionPeriod? {
        skProduct.subscription?.subscriptionPeriod.asAdaptySubscriptionPeriod
    }

    public var subscriptionGroupIdentifier: String? { skProduct.subscription?.subscriptionGroupID }

    public var localizedPrice: String? { skProduct.displayPrice }

    public var localizedSubscriptionPeriod: String? {
        guard let period = subscriptionPeriod else { return nil }
        return skProduct.subscriptionPeriodFormatStyle.locale.localized(period: period)
    }

    public var description: String {
        "(vendorProductId: \(vendorProductId), skProduct: \(skProduct))"
    }
}

struct SK2ProductWrapper: AdaptySK2Product {
    let skProduct: StoreKit.Product
}

