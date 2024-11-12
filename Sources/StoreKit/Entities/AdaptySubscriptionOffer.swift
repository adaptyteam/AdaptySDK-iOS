//
//  AdaptySubscriptionOffer.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 20.10.2022.
//

import Foundation

public struct AdaptySubscriptionOffer: Sendable, Hashable {
    package let _price: Price

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
