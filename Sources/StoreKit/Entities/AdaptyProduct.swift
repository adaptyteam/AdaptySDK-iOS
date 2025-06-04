//
//  AdaptyProduct.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 20.10.2022.
//

import StoreKit

public protocol AdaptyProduct: Sendable, CustomStringConvertible {
    /// Underlying system representation of the product.
    var sk1Product: StoreKit.SKProduct? { get }

    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
    var sk2Product: StoreKit.Product? { get }

    /// Unique identifier of a product from App Store Connect or Google Play Console.
    var vendorProductId: String { get }

    /// A description of the product.
    ///
    /// The description's language is determined by the storefront that the user's device is connected to, not the preferred language set on the device.
    var localizedDescription: String { get }

    /// The name of the product.
    ///
    /// The title's language is determined by the storefront that the user's device is connected to, not the preferred language set on the device.
    var localizedTitle: String { get }

    /// The cost of the product in the local currency.
    var price: Decimal { get }

    /// The currency code of the locale used to format the price of the product.
    var currencyCode: String? { get }

    /// The currency symbol of the locale used to format the price of the product.
    var currencySymbol: String? { get }

    /// The region code of the locale used to format the price of the product.
    var regionCode: String? { get }

    var priceLocale: Locale { get }
    
    /// A Boolean value that indicates whether the product is available for family sharing in App Store Connect. (Will be `false` for iOS version below 14.0 and macOS version below 11.0).
    var isFamilyShareable: Bool { get }

    /// The period details for products that are subscriptions. (Will be `nil` for iOS version below 11.2 and macOS version below 10.14.4).
    var subscriptionPeriod: AdaptySubscriptionPeriod? { get }

    /// The identifier of the subscription group to which the subscription belongs. (Will be `nil` for iOS version below 12.0 and macOS version below 10.14).
    var subscriptionGroupIdentifier: String? { get }

    /// The price's language is determined by the preferred language set on the device.
    var localizedPrice: String? { get }

    /// The period's language is determined by the preferred language set on the device.
    var localizedSubscriptionPeriod: String? { get }
}
