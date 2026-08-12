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
        let vendorProductId: String
        let subscriptionOfferIdentifier: AdaptySubscriptionOffer.Identifier?

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            vendorProductId = try container.decode(String.self, forKey: .vendorProductId)

            subscriptionOfferIdentifier =
                try container.decodeSubscriptionOfferIdentifierIfPresent(forKey: .subscription) ?? container.decodeIfPresent(AdaptySubscriptionOffer.Identifier.self, forKey: .subscriptionOfferIdentifier)
        }
    }
}

private enum CodingKeys: String, CodingKey {
    case vendorProductId = "vendor_product_id"
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
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(wrapped.vendorProductId, forKey: .vendorProductId)
            try container.encode(wrapped.localizedDescription, forKey: .localizedDescription)
            try container.encode(wrapped.localizedTitle, forKey: .localizedTitle)
            try container.encode(wrapped.isFamilyShareable, forKey: .isFamilyShareable)
            try container.encodeIfPresent(wrapped.regionCode, forKey: .regionCode)
            try container.encode(Price(from: wrapped), forKey: .price)
            try container.encodeIfPresent(Subscription(product: wrapped, offer: wrapped.subscriptionOffer), forKey: .subscription)
        }
    }
}
