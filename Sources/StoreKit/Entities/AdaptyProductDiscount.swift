//
//  AdaptyProductDiscount.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 20.10.2022.
//

import Foundation
import StoreKit

public struct AdaptyProductDiscount: Sendable, Hashable {
    fileprivate let _price: Price

    /// Unique identifier of a discount offer for a product.
    public let identifier: String?

    public let offerType: OfferType

    /// An information about period for a product discount.
    public let subscriptionPeriod: AdaptyProductSubscriptionPeriod

    /// A number of periods this product discount is available
    public let numberOfPeriods: Int

    /// A payment mode for this product discount.
    public let paymentMode: PaymentMode

    /// A formatted subscription period of a discount for a user's locale.
    public let localizedSubscriptionPeriod: String?

    /// A formatted number of periods of a discount for a user's locale.
    public let localizedNumberOfPeriods: String?

    /// Discount price of a product in a local currency.
    public var price: Decimal { _price.amount }

    /// The currency code of the locale used to format the price of the product.
    public var currencyCode: String? { _price.currencyCode }

    /// A formatted price of a discount for a user's locale.
    public var localizedPrice: String? { _price.localizedString }
}

extension Price {
    init(from product: AdaptyProductDiscount) {
        self = product._price
    }
}

extension AdaptyProductDiscount {
    init(discount: SK1Product.SubscriptionOffer, locale: Locale) {
        let period = AdaptyProductSubscriptionPeriod(subscriptionPeriod: discount.subscriptionPeriod)
        self.init(
            _price: Price(
                amount: discount.price as Decimal,
                currencyCode: locale.unfCurrencyCode,
                currencySymbol: locale.currencySymbol,
                localizedString: locale.localized(sk1Price: discount.price)
            ),
            identifier: discount.identifier,
            offerType: OfferType(type: discount.type),
            subscriptionPeriod: period,
            numberOfPeriods: discount.numberOfPeriods,
            paymentMode: PaymentMode(mode: discount.paymentMode),
            localizedSubscriptionPeriod: locale.localized(period: period),
            localizedNumberOfPeriods: locale.localized(period: period, numberOfPeriods: discount.numberOfPeriods)
        )
    }

    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
    init(
        offer: SK2Product.SubscriptionOffer,
        currencyCode: String?,
        priceLocale: Locale,
        periodLocale: Locale
    ) {
        let period = AdaptyProductSubscriptionPeriod(subscriptionPeriod: offer.period)

        self.init(
            _price: Price(
                amount: offer.price,
                currencyCode: currencyCode,
                currencySymbol: priceLocale.currencySymbol,
                localizedString: offer.displayPrice
            ),
            identifier: offer.id,
            offerType: OfferType(type: offer.type),
            subscriptionPeriod: period,
            numberOfPeriods: offer.periodCount,
            paymentMode: PaymentMode(mode: offer.paymentMode),
            localizedSubscriptionPeriod: periodLocale.localized(period: period),
            localizedNumberOfPeriods: periodLocale.localized(period: period, numberOfPeriods: offer.periodCount)
        )
    }
}

extension AdaptyProductDiscount: CustomStringConvertible {
    public var description: String {
        "(price: \(_price), type: \(offerType)"
            + (identifier.map { ", identifier: \($0)" } ?? "")
            + ", subscriptionPeriod: \(subscriptionPeriod), numberOfPeriods: \(numberOfPeriods), paymentMode: \(paymentMode)"
            + (localizedSubscriptionPeriod.map { ", localizedSubscriptionPeriod: \($0)" } ?? "")
            + (localizedNumberOfPeriods.map { ", localizedNumberOfPeriods: \($0)" } ?? "")
            + ")"
    }
}

extension AdaptyProductDiscount: Encodable {
    enum CodingKeys: String, CodingKey {
        case price
        case identifier
        case offerType = "offer_type"
        case numberOfPeriods = "number_of_periods"
        case paymentMode = "payment_mode"
        case subscriptionPeriod = "subscription_period"
        case localizedSubscriptionPeriod = "localized_subscription_period"
        case localizedNumberOfPeriods = "localized_number_of_periods"
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(identifier, forKey: .identifier)
        try container.encode(offerType, forKey: .offerType)
        try container.encode(_price, forKey: .price)
        try container.encode(numberOfPeriods, forKey: .numberOfPeriods)
        try container.encode(paymentMode, forKey: .paymentMode)
        try container.encode(subscriptionPeriod, forKey: .subscriptionPeriod)
        try container.encodeIfPresent(localizedSubscriptionPeriod, forKey: .localizedSubscriptionPeriod)
        try container.encodeIfPresent(localizedNumberOfPeriods, forKey: .localizedNumberOfPeriods)
    }
}
