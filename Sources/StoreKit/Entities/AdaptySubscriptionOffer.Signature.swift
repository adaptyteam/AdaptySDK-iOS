//
//  AdaptySubscriptionOffer.Signature.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 24.09.2022.
//

import Foundation

extension AdaptySubscriptionOffer {
    struct Signature: Sendable, Hashable {
        let keyIdentifier: String
        let nonce: UUID
        let signature: Data
        let timestamp: Int
    }
}

extension AdaptySubscriptionOffer.Signature: Decodable {
    enum CodingKeys: String, CodingKey {
        case keyIdentifier = "key_id"
        case signature
        case nonce
        case timestamp

        case attributes
    }

    init(from decoder: Decoder) throws {
        var container = try decoder.container(keyedBy: CodingKeys.self)
        if container.contains(.attributes) {
            container = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .attributes)
        }

        keyIdentifier = try container.decode(String.self, forKey: .keyIdentifier)
        nonce = try container.decode(UUID.self, forKey: .nonce)
        signature = try container.decode(Data.self, forKey: .signature)

        guard let timestamp = try Int(container.decode(String.self, forKey: .timestamp)) else {
            throw DecodingError.dataCorruptedError(forKey: .timestamp, in: container, debugDescription: "Wrong format of timestamp.")
        }
        self.timestamp = timestamp
    }
}
