//
//  AdaptySubscriptionOffer+Encodable.swift
//  AdaptyPlugin
//
//  Created by Aleksei Valiano on 12.11.2024.
//

import Adapty
import Foundation

extension AdaptySubscriptionOffer: Encodable {
    enum CodingKeys: String, CodingKey {
        case price
        case offerIdentifier = "offer_identifier"
        case numberOfPeriods = "number_of_periods"
        case paymentMode = "payment_mode"
        case subscriptionPeriod = "subscription_period"
        case localizedSubscriptionPeriod = "localized_subscription_period"
        case localizedNumberOfPeriods = "localized_number_of_periods"
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.offerIdentifier, forKey: .offerIdentifier)
        try container.encode(Price(from: self), forKey: .price)
        try container.encode(numberOfPeriods, forKey: .numberOfPeriods)
        try container.encode(paymentMode, forKey: .paymentMode)
        try container.encode(subscriptionPeriod, forKey: .subscriptionPeriod)
        try container.encodeIfPresent(localizedSubscriptionPeriod, forKey: .localizedSubscriptionPeriod)
        try container.encodeIfPresent(localizedNumberOfPeriods, forKey: .localizedNumberOfPeriods)
    }
}
