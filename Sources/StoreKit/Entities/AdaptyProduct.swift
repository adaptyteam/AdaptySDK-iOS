//
//  AdaptyProduct.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 16.09.2024
//

import StoreKit

public protocol AdaptyProduct: Sendable, CustomStringConvertible {
    var skProduct: StoreKit.Product { get }

    /// Regular pricing terms for the selected billing plan, without subscription offers.
    /// On older systems, up-front terms are built from the underlying product.
    /// Returns `nil` for non-subscription products or an unavailable non-up-front plan.
    var subscriptionPricingTerms: AdaptySubscriptionPricingTerms? { get }
}

public extension AdaptyProduct {
    /// Unique identifier of a product from App Store Connect or Google Play Console.
    var vendorProductId: String {
        skProduct.id
    }

    /// A description of the product.
    ///
    /// The description's language is determined by the storefront that the user's device is connected to, not the preferred language set on the device.
    var localizedDescription: String {
        skProduct.description
    }

    /// The name of the product.
    ///
    /// The title's language is determined by the storefront that the user's device is connected to, not the preferred language set on the device.
    var localizedTitle: String {
        skProduct.displayName
    }

    /// The cost of the product in the local currency.
    var price: Decimal {
        return subscriptionPricingTerms?.commitmentInfo.price ?? skProduct.price
    }

    /// The currency code of the locale used to format the price of the product.
    var currencyCode: String {
        skProduct.priceFormatStyle.currencyCode
    }

    /// The currency symbol of the locale used to format the price of the product.
    var currencySymbol: String? {
        skProduct.priceFormatStyle.locale.currencySymbol
    }

    /// The region code of the locale used to format the price of the product.
    var regionCode: String? {
        skProduct.priceFormatStyle.locale.unfRegionCode
    }

    var priceLocale: Locale {
        skProduct.priceFormatStyle.locale
    }

    /// A Boolean value that indicates whether the product is available for family sharing in App Store Connect. (Will be `false` for iOS version below 14.0 and macOS version below 11.0).
    var isFamilyShareable: Bool {
        skProduct.isFamilyShareable
    }

    /// The normalized commitment period of the selected billing plan.
    /// Falls back to the underlying StoreKit subscription period when pricing terms are unavailable.

    var subscriptionPeriod: AdaptySubscriptionPeriod? {
        subscriptionPricingTerms?.commitmentInfo.period
    }

    /// The identifier of the subscription group to which the subscription belongs. (Will be `nil` for iOS version below 12.0 and macOS version below 10.14).
    var subscriptionGroupIdentifier: String? {
        skProduct.subscription?.subscriptionGroupID
    }

    /// The price's language is determined by the preferred language set on the device.
    var localizedPrice: String {
        subscriptionPricingTerms?.commitmentInfo.localizedPrice ?? skProduct.displayPrice
    }

    /// The period's language is determined by the preferred language set on the device.
    var localizedSubscriptionPeriod: String? {
        guard let period = subscriptionPeriod else { return nil }
        return skProduct.subscriptionPeriodFormatStyle.locale.localized(period: period)
    }

    var description: String {
        "(vendorProductId: \(vendorProductId), skProduct: \(skProduct))"
    }
}
