//
//  AdaptySubscriptionOffer.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 20.10.2022.
//

import Foundation

public struct AdaptySubscriptionOffer: Sendable, Hashable {
    /// Unique identifier of a discount offer for a product.
    public var identifier: String? { offerIdentifier.identifier }

    public var offerType: OfferType { offerIdentifier.asOfferType }

    package let offerIdentifier: Identifier

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
    public let price: Decimal

    /// The currency code of the locale used to format the price of the product.
    public let currencyCode: String?

    /// A formatted price of a discount for a user's locale.
    public var localizedPrice: String?

    init(
        price: Decimal,
        currencyCode: String?,
        localizedPrice: String?,
        offerIdentifier: Identifier,
        subscriptionPeriod: AdaptySubscriptionPeriod,
        numberOfPeriods: Int,
        paymentMode: PaymentMode,
        localizedSubscriptionPeriod: String?,
        localizedNumberOfPeriods: String?
    ) {
        self.price = price
        self.currencyCode = currencyCode
        self.localizedPrice = localizedPrice
        self.offerIdentifier = offerIdentifier
        self.subscriptionPeriod = subscriptionPeriod
        self.numberOfPeriods = numberOfPeriods
        self.paymentMode = paymentMode
        self.localizedSubscriptionPeriod = localizedSubscriptionPeriod
        self.localizedNumberOfPeriods = localizedNumberOfPeriods
    }
}

extension AdaptySubscriptionOffer: CustomStringConvertible {
    public var description: String {
        "(price: \(price)"
            + (localizedPrice.map { ", localizedPrice: \($0)" } ?? "")
            + ", type: \(offerType)"
            + (identifier.map { ", identifier: \($0)" } ?? "")
            + ", subscriptionPeriod: \(subscriptionPeriod), numberOfPeriods: \(numberOfPeriods), paymentMode: \(paymentMode)"
            + (localizedSubscriptionPeriod.map { ", localizedSubscriptionPeriod: \($0)" } ?? "")
            + (localizedNumberOfPeriods.map { ", localizedNumberOfPeriods: \($0)" } ?? "")
            + ")"
    }
}
