//
//  AdaptySK1Product.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 16.09.2024
//

import StoreKit

struct AdaptySK1Product: AdaptyProduct {
    let skProduct: SK1Product

    var sk1Product: SK1Product? { skProduct }

    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
    var sk2Product: SK2Product? { nil }

    var vendorProductId: String { skProduct.productIdentifier }

    var localizedDescription: String { skProduct.localizedDescription }

    var localizedTitle: String { skProduct.localizedTitle }

    var price: Decimal { skProduct.price as Decimal }

    var currencyCode: String? { skProduct.priceLocale.unfCurrencyCode }

    var currencySymbol: String? { skProduct.priceLocale.currencySymbol }

    var regionCode: String? { skProduct.priceLocale.unfRegionCode }

    var isFamilyShareable: Bool { skProduct.unfIsFamilyShareable }

    var subscriptionPeriod: AdaptyProductSubscriptionPeriod? {
        skProduct.subscriptionPeriod?.asAdaptyProductSubscriptionPeriod
    }
    
    var subscriptionGroupIdentifier: String? { skProduct.subscriptionGroupIdentifier }

    var localizedPrice: String? {
        skProduct.priceLocale.localized(sk1Price: skProduct.price)
    }

    var localizedSubscriptionPeriod: String? {
        guard let period = subscriptionPeriod else { return nil }
        return skProduct.priceLocale.localized(period: period)
    }
}

extension AdaptySK1Product: CustomStringConvertible {
    var description: String {
        "(vendorProductId: \(vendorProductId), skProduct: \(skProduct))"
    }
}

extension SK1Product {
    var asAdaptyProduct: AdaptySK1Product { .init(skProduct: self) }
}
