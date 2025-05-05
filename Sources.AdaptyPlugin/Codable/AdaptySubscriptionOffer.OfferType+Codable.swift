//
//  AdaptySubscriptionOffer.OfferType.swift
//  AdaptyPlugin
//
//  Created by Aleksei Valiano on 12.11.2024.
//

import Adapty
import Foundation

extension AdaptySubscriptionOffer.OfferType: Codable {

    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        self =
            switch try container.decode(CodingValues.self) {
            case .introductory:
                .introductory
            case .promotional:
                .promotional
            case .winBack:
                .winBack
            }
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(encodedValue)
    }
}
