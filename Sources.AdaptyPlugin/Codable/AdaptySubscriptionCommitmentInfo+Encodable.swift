//
//  AdaptySubscriptionCommitmentInfo+Encodable.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 28.09.2026.
//

import Adapty
import Foundation

extension AdaptySubscriptionCommitmentInfo: EncodableWithConfiguration {
    private enum CodingKeys: String, CodingKey {
        case price
        case period
    }

    public func encode(to encoder: any Encoder, configuration: AdaptyProductEncodingConfiguration) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(Price(from: self), forKey: .price, configuration: configuration.price)
        try container.encode(period, forKey: .period)
    }
}
