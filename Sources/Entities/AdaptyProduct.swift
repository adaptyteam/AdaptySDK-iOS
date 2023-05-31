//
//  AdaptyProduct.swift
//  Adapty
//
//  Created by Aleksei Valiano on 20.10.2022.
//

import StoreKit

public protocol AdaptyProduct {
    var vendorProductId: String { get }
    var skProduct: SKProduct { get }
}

extension AdaptyProduct {
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

    /// The currency code of the locale used to format the price of the product.
    public var currencyCode: String? { skProduct.priceLocale.currencyCode }

    /// The currency symbol of the locale used to format the price of the product.
    public var currencySymbol: String? { skProduct.priceLocale.currencySymbol }

    /// The region code of the locale used to format the price of the product.
    public var regionCode: String? { skProduct.priceLocale.regionCode }

    /// A Boolean value that indicates whether the product is available for family sharing in App Store Connect. (Will be `false` for iOS version below 14.0 and macOS version below 11.0).
    public var isFamilyShareable: Bool {
        #if swift(>=5.3)
            if #available(iOS 14.0, macOS 11.0, *) {
                return skProduct.isFamilyShareable
            }
        #endif
        return false
    }

    /// The period details for products that are subscriptions. (Will be `nil` for iOS version below 11.2 and macOS version below 10.14.4).
    public var subscriptionPeriod: AdaptyProductSubscriptionPeriod? {
        if #available(iOS 11.2, macOS 10.14.4, *), let period = skProduct.subscriptionPeriod {
            return AdaptyProductSubscriptionPeriod(subscriptionPeriod: period)
        }
        return nil
    }

    /// The object containing introductory price information for the product. (Will be `nil` for iOS version below 11.2 and macOS version below 10.14.4).
    public var introductoryDiscount: AdaptyProductDiscount? {
        skProduct.adaptyIntroductoryDiscount
    }

    /// The identifier of the subscription group to which the subscription belongs. (Will be `nil` for iOS version below 12.0 and macOS version below 10.14).
    public var subscriptionGroupIdentifier: String? {
        if #available(iOS 12.0, macOS 10.14, *) {
            return skProduct.subscriptionGroupIdentifier
        }
        return nil
    }

    /// An array of subscription offers available for the auto-renewable subscription. (Will be empty for iOS version below 12.2 and macOS version below 10.14.4).
    public var discounts: [AdaptyProductDiscount] {
        if #available(iOS 12.2, macOS 10.14.4, *) {            
            return skProduct.discounts.map { discount in
                AdaptyProductDiscount(discount: discount, locale: skProduct.priceLocale)
            }
        }
        return []
    }

    /// The price's language is determined by the preferred language set on the device.
    public var localizedPrice: String? {
        skProduct.priceLocale.localized(price: skProduct.price)
    }

    /// The period's language is determined by the preferred language set on the device.
    public var localizedSubscriptionPeriod: String? {
        if #available(iOS 11.2, macOS 10.14.4, *), let period = skProduct.subscriptionPeriod {
            return skProduct.priceLocale.localized(period: period)
        }
        return nil
    }
}

extension SKProduct {
    var adaptyIntroductoryDiscount: AdaptyProductDiscount? {
        if #available(iOS 11.2, macOS 10.14.4, *), let discount = introductoryPrice {
            return AdaptyProductDiscount(discount: discount, locale: priceLocale)
        }
        return nil
    }
}


enum ProductCodingKeys: String, CodingKey {
    case vendorProductId = "vendor_product_id"
    case version = "timestamp"

    case promotionalOfferId = "promotional_offer_id"
    case variationId = "variation_id"
    case paywallABTestName = "paywall_ab_test_name"
    case paywallName = "paywall_name"

    case localizedDescription = "localized_description"
    case localizedTitle = "localized_title"
    case price
    case currencyCode = "currency_code"
    case currencySymbol = "currency_symbol"
    case regionCode = "region_code"
    case isFamilyShareable = "is_family_shareable"
    case subscriptionPeriod = "subscription_period"
    case introductoryDiscount = "introductory_discount"
    case subscriptionGroupIdentifier = "subscription_group_identifier"
    case discounts
    case localizedPrice = "localized_price"
    case localizedSubscriptionPeriod = "localized_subscription_period"
}
