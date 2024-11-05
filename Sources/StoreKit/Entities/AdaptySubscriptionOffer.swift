//
//  AdaptySubscriptionOffer.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 20.10.2022.
//

import Foundation

public struct AdaptySubscriptionOffer: Sendable, Hashable {
    fileprivate let _price: Price

    /// Unique identifier of a discount offer for a product.
    public var identifier: String? { offerTypeWithIdentifier.identifier }

    public var offerType: OfferType { offerTypeWithIdentifier.asOfferType }

    let offerTypeWithIdentifier: OfferTypeWithIdentifier
    
    /// An information about period for a product discount.
    public let subscriptionPeriod: AdaptySubscriptionPeriod

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

    init(
        _price: Price,
        offerTypeWithIdentifier: OfferTypeWithIdentifier,
        subscriptionPeriod: AdaptySubscriptionPeriod,
        numberOfPeriods: Int,
        paymentMode: PaymentMode,
        localizedSubscriptionPeriod: String?,
        localizedNumberOfPeriods: String?
    ) {
        self._price = _price
        self.offerTypeWithIdentifier = offerTypeWithIdentifier
        self.subscriptionPeriod = subscriptionPeriod
        self.numberOfPeriods = numberOfPeriods
        self.paymentMode = paymentMode
        self.localizedSubscriptionPeriod = localizedSubscriptionPeriod
        self.localizedNumberOfPeriods = localizedNumberOfPeriods
    }
}

extension Price {
    init(from product: AdaptySubscriptionOffer) {
        self = product._price
    }
}

extension AdaptySubscriptionOffer: CustomStringConvertible {
    public var description: String {
        "(price: \(_price), type: \(offerType)"
            + (identifier.map { ", identifier: \($0)" } ?? "")
            + ", subscriptionPeriod: \(subscriptionPeriod), numberOfPeriods: \(numberOfPeriods), paymentMode: \(paymentMode)"
            + (localizedSubscriptionPeriod.map { ", localizedSubscriptionPeriod: \($0)" } ?? "")
            + (localizedNumberOfPeriods.map { ", localizedNumberOfPeriods: \($0)" } ?? "")
            + ")"
    }
}

extension AdaptySubscriptionOffer: Encodable {
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
