//
//  AdaptyPluginProductSubscription+Codable.swift
//  AdaptyPlugin
//
//  Created by Aleksei Valiano on 06.07.2026.
//

import Adapty
import AdaptyCodable
import Foundation

struct Subscription: Encodable {
    let groupIdentifier: String
    let period: AdaptySubscriptionPeriod
    let localizedPeriod: String?
    let offer: AdaptySubscriptionOffer?

    init?(
        product: AdaptyProduct,
        offer: AdaptySubscriptionOffer?
    ) {
        guard let groupIdentifier = product.subscriptionGroupIdentifier,
              let period = product.subscriptionPeriod
        else { return nil }

        self.groupIdentifier = groupIdentifier
        self.period = period
        localizedPeriod = product.localizedSubscriptionPeriod
        self.offer = offer
    }

    enum CodingKeys: String, CodingKey {
        case groupIdentifier = "group_identifier"
        case period
        case localizedPeriod = "localized_period"
        case offer
    }
}

private enum SubscriptionCodingKeys: String, CodingKey {
    case offer
}

private enum SubscriptionOfferCodingKeys: String, CodingKey {
    case offerIdentifier = "offer_identifier"
}

extension KeyedDecodingContainer {
    func decodeSubscriptionOfferIdentifierIfPresent(forKey subscriptionKey: Key) throws -> AdaptySubscriptionOffer.Identifier? {
        guard exist(subscriptionKey)
        else { return nil }

        let subscriptionContainer = try nestedContainer(keyedBy: SubscriptionCodingKeys.self, forKey: subscriptionKey)
        guard subscriptionContainer.exist(.offer)
        else { return nil }

        let offerContainer = try subscriptionContainer.nestedContainer(keyedBy: SubscriptionOfferCodingKeys.self, forKey: .offer)
        return try offerContainer.decodeIfPresent(AdaptySubscriptionOffer.Identifier.self, forKey: .offerIdentifier)
    }
}
