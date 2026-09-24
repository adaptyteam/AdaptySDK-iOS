//
//  AdaptyPluginPromotedProduct+Codable.swift
//  AdaptyPlugin
//
//  Created by Codex on 03.07.2026.
//

import Adapty
import Foundation


extension Request {
    struct AdaptyPluginPromotedProduct: Decodable {
        let purchaseIntentId: String
        let vendorProductId: String
        let billingPlan: AdaptySubscriptionBillingPlan?
        let subscriptionOfferIdentifier: AdaptySubscriptionOffer.Identifier?

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            purchaseIntentId = try container.decode(String.self, forKey: .purchaseIntentId)
            vendorProductId = try container.decode(String.self, forKey: .vendorProductId)
            billingPlan = try container.decodeSubscriptionBillingPlanIfPresent(forKey: .subscription)
            subscriptionOfferIdentifier = try container.decodeSubscriptionOfferIdentifierIfPresent(forKey: .subscription)
        }
    }
}

private enum CodingKeys: String, CodingKey {
    case purchaseIntentId = "purchase_intent_id"
    case vendorProductId = "vendor_product_id"
    case billingPlan = "billing_plan_id"
    case subscriptionOfferIdentifier = "subscription_offer_identifier"

    case localizedDescription = "localized_description"
    case localizedTitle = "localized_title"
    case price
    case regionCode = "region_code"
    case isFamilyShareable = "is_family_shareable"
    
    case subscription
}

extension Response {
    struct AdaptyPluginPromotedProduct: Encodable {
        let wrapped: AdaptyPromotedProduct

        init(_ wrapped: AdaptyPromotedProduct) {
            self.wrapped = wrapped
        }

        func encode(to encoder: Encoder) throws {
            let configuration = AdaptyProductEncodingConfiguration(product: wrapped)
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(wrapped.purchaseIntentId, forKey: .purchaseIntentId)
            try container.encode(wrapped.vendorProductId, forKey: .vendorProductId)
            try container.encode(wrapped.localizedDescription, forKey: .localizedDescription)
            try container.encode(wrapped.localizedTitle, forKey: .localizedTitle)
            try container.encode(wrapped.isFamilyShareable, forKey: .isFamilyShareable)
            try container.encodeIfPresent(wrapped.regionCode, forKey: .regionCode)
            try container.encode(Price(from: wrapped), forKey: .price, configuration: configuration.price)
            try container.encodeIfPresent(Subscription(product: wrapped, offer: wrapped.subscriptionOffer), forKey: .subscription, configuration: configuration)
        }
    }
}
