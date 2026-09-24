//
//  AdaptyPluginProductSubscription+Codable.swift
//  AdaptyPlugin
//
//  Created by Aleksei Valiano on 06.07.2026.
//

import Adapty
import AdaptyCodable
import Foundation

struct Subscription: EncodableWithConfiguration {
    let groupIdentifier: String
    let period: AdaptySubscriptionPeriod
    let localizedPeriod: String?
    let pricingTerms: AdaptySubscriptionPricingTerms
    let offer: AdaptySubscriptionOffer?

    init?(
        product: AdaptyProduct,
        offer: AdaptySubscriptionOffer?
    ) {
        guard let groupIdentifier = product.subscriptionGroupIdentifier,
              let period = product.subscriptionPeriod,
              let subscriptionPricingTerms = product.subscriptionPricingTerms
        else { return nil }

        self.groupIdentifier = groupIdentifier
        self.period = period
        localizedPeriod = product.localizedSubscriptionPeriod
        pricingTerms = subscriptionPricingTerms
        self.offer = offer
    }

    enum CodingKeys: String, CodingKey {
        case groupIdentifier = "group_identifier"
        case period
        case localizedPeriod = "localized_period"
        case pricingTerms = "pricing_terms"
        case offer
    }

    func encode(to encoder: any Encoder, configuration: AdaptyProductEncodingConfiguration) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(groupIdentifier, forKey: .groupIdentifier)
        try container.encode(period, forKey: .period)
        try container.encodeIfPresent(localizedPeriod, forKey: .localizedPeriod)
        try container.encode(pricingTerms, forKey: .pricingTerms, configuration: configuration)
        try container.encodeIfPresent(offer, forKey: .offer, configuration: configuration)
    }
}

private enum SubscriptionCodingKeys: String, CodingKey {
    case pricingTerms = "pricing_terms"
    case offer
}

private enum SubscriptionOfferCodingKeys: String, CodingKey {
    case offerIdentifier = "offer_identifier"
}

private enum PricingTermsCodingKeys: String, CodingKey {
    case billingPlan = "billing_plan_id"
}

extension KeyedDecodingContainer {
    func decodeSubscriptionBillingPlanIfPresent(forKey subscriptionKey: Key) throws -> AdaptySubscriptionBillingPlan? {
        guard exist(subscriptionKey) else { return nil }

        let subscriptionContainer = try nestedContainer(keyedBy: SubscriptionCodingKeys.self, forKey: subscriptionKey)
        guard subscriptionContainer.exist(.pricingTerms) else { return nil }

        let termsContainer = try subscriptionContainer.nestedContainer(keyedBy: PricingTermsCodingKeys.self, forKey: .pricingTerms)
        return try termsContainer.decodeIfPresent(AdaptySubscriptionBillingPlan.self, forKey: .billingPlan)
    }

    func decodeSubscriptionOfferIdentifierIfPresent(forKey subscriptionKey: Key) throws -> AdaptySubscriptionOffer.Identifier? {
        guard exist(subscriptionKey) else { return nil }

        let subscriptionContainer = try nestedContainer(keyedBy: SubscriptionCodingKeys.self, forKey: subscriptionKey)
        guard subscriptionContainer.exist(.offer) else { return nil }

        let offerContainer = try subscriptionContainer.nestedContainer(keyedBy: SubscriptionOfferCodingKeys.self, forKey: .offer)
        return try offerContainer.decodeIfPresent(AdaptySubscriptionOffer.Identifier.self, forKey: .offerIdentifier)
    }
}
