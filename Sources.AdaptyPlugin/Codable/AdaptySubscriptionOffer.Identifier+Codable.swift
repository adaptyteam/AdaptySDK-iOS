//
//  AdaptySubscriptionOffer.Identifier.swift
//  AdaptyPlugin
//
//  Created by Aleksei Valiano on 12.11.2024.
//

import Adapty
import Foundation

extension AdaptySubscriptionOffer.Identifier: Codable {
    private enum CodingKeys: String, CodingKey {
        case offerType = "type"
        case offerId = "id"
    }

    package init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let offerType = try container.decode(AdaptySubscriptionOfferType.self, forKey: .offerType)
        switch offerType {
        case .introductory:
            self = .introductory
        case .promotional:
            self = try .promotional(container.decode(String.self, forKey: .offerId))
        case .winBack:
            self = try .winBack(container.decode(String.self, forKey: .offerId))
        case .code:
            self = try .code(container.decodeIfPresent(String.self, forKey: .offerId))
        }
    }

    package func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(offerType, forKey: .offerType)
        try container.encodeIfPresent(offerId, forKey: .offerId)
    }
}
