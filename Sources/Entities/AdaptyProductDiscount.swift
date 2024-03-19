//
//  AdaptyProductDiscount.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 20.10.2022.
//

import Foundation
import StoreKit

public struct AdaptyProductDiscount {
    let priceValue: AdaptyPrice

    /// Discount price of a product in a local currency.
    public var price: Decimal { priceValue.amount }

    /// Unique identifier of a discount offer for a product.
    public let identifier: String?

    /// An information about period for a product discount.
    public let subscriptionPeriod: AdaptyProductSubscriptionPeriod

    /// A number of periods this product discount is available
    public let numberOfPeriods: Int

    /// A payment mode for this product discount.
    public let paymentMode: PaymentMode

    /// A formatted price of a discount for a user's locale.
    public var localizedPrice: String? { priceValue.localizedString }

    /// A formatted subscription period of a discount for a user's locale.
    public let localizedSubscriptionPeriod: String?

    /// A formatted number of periods of a discount for a user's locale.
    public let localizedNumberOfPeriods: String?
}

extension AdaptyProductDiscount {
    init(discount: SKProductDiscount, locale: Locale) {
        self.init(
            priceValue: AdaptyPrice(value: discount.price, locale: locale),
            identifier: discount.identifier,
            subscriptionPeriod: AdaptyProductSubscriptionPeriod(subscriptionPeriod: discount.subscriptionPeriod),
            numberOfPeriods: discount.numberOfPeriods,
            paymentMode: PaymentMode(mode: discount.paymentMode),
            localizedSubscriptionPeriod: locale.ext.localized(period: discount.subscriptionPeriod),
            localizedNumberOfPeriods: locale.ext.localized(numberOfPeriods: discount)
        )
    }
}

extension AdaptyProductDiscount: CustomStringConvertible {
    public var description: String {
        "(price: \(price)"
            + (identifier.map { "identifier: \($0), " } ?? "")
            + ", subscriptionPeriod: \(subscriptionPeriod), numberOfPeriods: \(numberOfPeriods), paymentMode: \(paymentMode)"
            + (localizedPrice.map { "localizedPrice: \($0), " } ?? "")
            + (localizedSubscriptionPeriod.map { "localizedSubscriptionPeriod: \($0), " } ?? "")
            + (localizedNumberOfPeriods.map { "localizedNumberOfPeriods: \($0), " } ?? "")
            + ")"
    }
}

extension AdaptyProductDiscount: Equatable, Sendable {}

extension AdaptyProductDiscount: Encodable {
    enum CodingKeys: String, CodingKey {
        case price
        case identifier
        case numberOfPeriods = "number_of_periods"
        case paymentMode = "payment_mode"
        case subscriptionPeriod = "subscription_period"
        case localizedSubscriptionPeriod = "localized_subscription_period"
        case localizedNumberOfPeriods = "localized_number_of_periods"
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(identifier, forKey: .identifier)

        try container.encode(priceValue, forKey: .price)
        try container.encode(numberOfPeriods, forKey: .numberOfPeriods)
        try container.encode(paymentMode, forKey: .paymentMode)
        try container.encode(subscriptionPeriod, forKey: .subscriptionPeriod)
        try container.encodeIfPresent(localizedSubscriptionPeriod, forKey: .localizedSubscriptionPeriod)
        try container.encodeIfPresent(localizedNumberOfPeriods, forKey: .localizedNumberOfPeriods)
    }
}
