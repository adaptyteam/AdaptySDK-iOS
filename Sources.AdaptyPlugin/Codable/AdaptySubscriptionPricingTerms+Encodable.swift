//
//  AdaptySubscriptionPricingTerms+Encodable.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 28.09.2026.
//

import Adapty
import Foundation

extension AdaptySubscriptionPricingTerms: EncodableWithConfiguration {
    private enum CodingKeys: String, CodingKey {
        case billingPlan = "billing_plan_id"
        case billingPrice = "billing_price"
        case billingPeriod = "billing_period"
        case commitmentInfo = "commitment_info"
    }

    public func encode(to encoder: any Encoder, configuration: AdaptyProductEncodingConfiguration ) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(billingPlan, forKey: .billingPlan)
        try container.encode(Price(from: self), forKey: .billingPrice, configuration: configuration.price)
        try container.encode(billingPeriod, forKey: .billingPeriod)
        try container.encode(commitmentInfo, forKey: .commitmentInfo, configuration: configuration)
    }
}
