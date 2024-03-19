//
//  AdaptyPaywall.ProductReference.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 11.05.2023
//

import Foundation

extension AdaptyPaywall {
    struct ProductReference {
        let adaptyProductId: String
        let vendorId: String
        let promotionalOfferId: String?
        var promotionalOfferEligibility: Bool { promotionalOfferId != nil }
    }
}

extension AdaptyPaywall.ProductReference: CustomStringConvertible {
    public var description: String {
        "(vendorId: \(vendorId), adaptyProductId: \(adaptyProductId), promotionalOfferId: \(promotionalOfferId ?? "nil")))"
    }
}

extension AdaptyPaywall.ProductReference: Sendable, Equatable {}

extension AdaptyPaywall.ProductReference: Codable {
    enum CodingKeys: String, CodingKey {
        case vendorId = "vendor_product_id"
        case adaptyProductId = "adapty_product_id"
        case promotionalOfferEligibility = "promotional_offer_eligibility"
        case promotionalOfferId = "promotional_offer_id"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        vendorId = try container.decode(String.self, forKey: .vendorId)
        adaptyProductId = try container.decode(String.self, forKey: .adaptyProductId)
        if (try? container.decode(Bool.self, forKey: .promotionalOfferEligibility)) ?? true {
            promotionalOfferId = try container.decodeIfPresent(String.self, forKey: .promotionalOfferId)
        } else {
            promotionalOfferId = nil
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(vendorId, forKey: .vendorId)
        try container.encode(adaptyProductId, forKey: .adaptyProductId)
        try container.encodeIfPresent(promotionalOfferId, forKey: .promotionalOfferId)
    }
}
