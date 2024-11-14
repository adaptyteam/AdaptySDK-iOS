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
        case offerIdentifier = "offer_identifier"
        case phases
    }

    enum PhaseCodingKeys: String, CodingKey {
        case price
        case numberOfPeriods = "number_of_periods"
        case paymentMode = "payment_mode"
        case subscriptionPeriod = "subscription_period"
        case localizedSubscriptionPeriod = "localized_subscription_period"
        case localizedNumberOfPeriods = "localized_number_of_periods"
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.offerIdentifier, forKey: .offerIdentifier)
        var phases = container.nestedUnkeyedContainer(forKey: .phases)
        var phase = phases.nestedContainer(keyedBy: PhaseCodingKeys.self)
        try phase.encode(Price(from: self), forKey: .price)
        try phase.encode(numberOfPeriods, forKey: .numberOfPeriods)
        try phase.encode(paymentMode, forKey: .paymentMode)
        try phase.encode(subscriptionPeriod, forKey: .subscriptionPeriod)
        try phase.encodeIfPresent(localizedSubscriptionPeriod, forKey: .localizedSubscriptionPeriod)
        try phase.encodeIfPresent(localizedNumberOfPeriods, forKey: .localizedNumberOfPeriods)
    }
}
