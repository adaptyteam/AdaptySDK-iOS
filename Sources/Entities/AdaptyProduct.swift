//
//  AdaptyProduct.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 20.10.2022.
//

import StoreKit

public protocol AdaptyProduct {
    /// Unique identifier of a product from App Store Connect or Google Play Console.
    var vendorProductId: String { get }
    /// Underlying system representation of the product.
    var skProduct: SKProduct { get }
    /// An identifier of a promotional offer, provided by Adapty for this specific user.
    var promotionalOfferId: String? { get }
}

extension AdaptyProduct {
    /// Unique identifier of a product from App Store Connect or Google Play Console.
    public var vendorProductId: String { skProduct.productIdentifier }

    /// User's eligibility for the promotional offers. Check this property before displaying info about promotional offers.
    public var promotionalOfferEligibility: Bool { promotionalOfferId != nil }

    /// A description of the product.
    ///
    /// The description's language is determined by the storefront that the user's device is connected to, not the preferred language set on the device.
    public var localizedDescription: String { skProduct.localizedDescription }

    /// The name of the product.
    ///
    /// The title's language is determined by the storefront that the user's device is connected to, not the preferred language set on the device.
    public var localizedTitle: String { skProduct.localizedTitle }

    /// The cost of the product in the local currency.
    public var price: Decimal { skProduct.price.decimalValue }

    var priceValue: AdaptyPrice { AdaptyPrice(value: skProduct.price, locale: skProduct.priceLocale) }

    /// The currency code of the locale used to format the price of the product.
    public var currencyCode: String? { skProduct.priceLocale.ext.currencyCode }

    /// The currency symbol of the locale used to format the price of the product.
    public var currencySymbol: String? { skProduct.priceLocale.currencySymbol }

    /// The region code of the locale used to format the price of the product.
    public var regionCode: String? { skProduct.priceLocale.ext.regionCode }

    /// A Boolean value that indicates whether the product is available for family sharing in App Store Connect. (Will be `false` for iOS version below 14.0 and macOS version below 11.0).
    public var isFamilyShareable: Bool {
        guard #available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, visionOS 1.0, *) else { return false }
        return skProduct.isFamilyShareable
    }

    /// The period details for products that are subscriptions. (Will be `nil` for iOS version below 11.2 and macOS version below 10.14.4).
    public var subscriptionPeriod: AdaptyProductSubscriptionPeriod? {
        guard let period = skProduct.subscriptionPeriod else { return nil }
        return AdaptyProductSubscriptionPeriod(subscriptionPeriod: period)
    }

    /// The object containing introductory price information for the product. (Will be `nil` for iOS version below 11.2 and macOS version below 10.14.4).
    public var introductoryDiscount: AdaptyProductDiscount? {
        skProduct.adaptyIntroductoryDiscount
    }

    /// The identifier of the subscription group to which the subscription belongs. (Will be `nil` for iOS version below 12.0 and macOS version below 10.14).
    public var subscriptionGroupIdentifier: String? {
        skProduct.subscriptionGroupIdentifier
    }

    /// An array of subscription offers available for the auto-renewable subscription. (Will be empty for iOS version below 12.2 and macOS version below 10.14.4).
    public var discounts: [AdaptyProductDiscount] {
        skProduct.discounts.map { discount in
            AdaptyProductDiscount(discount: discount, locale: skProduct.priceLocale)
        }
    }

    public func discount(byIdentifier identifier: String) -> AdaptyProductDiscount? {
        guard let discount = skProduct.discounts.first(where: { $0.identifier == identifier })
        else { return nil }
        return AdaptyProductDiscount(discount: discount, locale: skProduct.priceLocale)
    }

    /// The price's language is determined by the preferred language set on the device.
    public var localizedPrice: String? {
        skProduct.priceLocale.ext.localized(price: skProduct.price)
    }

    /// The period's language is determined by the preferred language set on the device.
    public var localizedSubscriptionPeriod: String? {
        guard let period = skProduct.subscriptionPeriod else { return nil }
        return skProduct.priceLocale.ext.localized(period: period)
    }
}

private extension SK1Product {
    var adaptyIntroductoryDiscount: AdaptyProductDiscount? {
        guard let discount = introductoryPrice else { return nil }
        return AdaptyProductDiscount(discount: discount, locale: priceLocale)
    }
}
