//
//  SignSubscriptionOfferResponse.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 24.09.2022.
//
import StoreKit

struct SignSubscriptionOfferResponse: Decodable, Equatable {
    let keyIdentifier: String
    let nonce: UUID
    let signature: String
    let timestamp: NSNumber

    enum CodingKeys: String, CodingKey {
        case keyIdentifier = "key_id"
        case signature
        case nonce
        case timestamp
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        keyIdentifier = try container.decode(String.self, forKey: .keyIdentifier)
        nonce = try container.decode(UUID.self, forKey: .nonce)
        signature = try container.decode(String.self, forKey: .signature)
        guard let timestamp = try Int64(container.decode(String.self, forKey: .timestamp)) else {
            throw DecodingError.dataCorruptedError(forKey: .timestamp, in: container, debugDescription: "Wrong format of timestamp.")
        }
        self.timestamp = NSNumber(value: timestamp)
    }

    func discount(identifier: String) -> SKPaymentDiscount {
        SKPaymentDiscount(identifier: identifier, keyIdentifier: keyIdentifier, nonce: nonce, signature: signature, timestamp: timestamp)
    }
}
