//
//  AdaptySubscriptionOffer.OfferTypeWithIdentifier.swift
//  AdaptyPlugin
//
//  Created by Aleksei Valiano on 12.11.2024.
//

import Adapty
import Foundation

extension AdaptySubscriptionOffer.OfferTypeWithIdentifier: Codable {
    private enum CodingKeys: String, CodingKey {
        case offerType = "type"
        case offerId = "id"
    }

    package init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let offerType = try container.decode(AdaptySubscriptionOffer.OfferType.self, forKey: .offerType)
        switch offerType {
        case .introductory:
            self = .introductory
        case .promotional:
            self = try .promotional(container.decode(String.self, forKey: .offerId))
        case .winBack:
            self = try .winBack(container.decode(String.self, forKey: .offerId))
        }
    }

    package func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .introductory:
            try container.encode(AdaptySubscriptionOffer.OfferType.introductory, forKey: .offerType)
        case .promotional(let id):
            try container.encode(AdaptySubscriptionOffer.OfferType.promotional, forKey: .offerType)
            try container.encode(id, forKey: .offerId)
        case .winBack(let id):
            try container.encode(AdaptySubscriptionOffer.OfferType.winBack, forKey: .offerType)
            try container.encode(id, forKey: .offerId)
        }
    }
}

