//
//  AdaptyPaywall.ProductReference.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 11.05.2023
//

import Foundation

extension AdaptyPaywall {
    struct ProductReference: Sendable, Hashable {
        let paywallProductIndex: Int
        let adaptyProductId: String
        let vendorId: String
        let promotionalOfferId: String?
        let winBackOfferId: String?
    }
}

extension AdaptyPaywall.ProductReference: CustomStringConvertible {
    public var description: String {
        "(vendorId: \(vendorId), adaptyProductId: \(adaptyProductId), promotionalOfferId: \(promotionalOfferId ?? "nil")))"
    }
}

extension AdaptyPaywall.ProductReference: Encodable {
    enum CodingKeys: String, CodingKey {
        case vendorId = "vendor_product_id"
        case adaptyProductId = "adapty_product_id"
        case promotionalOfferEligibility = "promotional_offer_eligibility"
        case promotionalOfferId = "promotional_offer_id"
        case winBackOfferId = "win_back_offer_id"
    }

    init(from container: KeyedDecodingContainer<CodingKeys>, index: Int) throws {
        self.paywallProductIndex = index
        self.adaptyProductId = try container.decode(String.self, forKey: .adaptyProductId)
        self.vendorId = try container.decode(String.self, forKey: .vendorId)
        self.winBackOfferId = try container.decodeIfPresent(String.self, forKey: .winBackOfferId)

        self.promotionalOfferId =
            if (try? container.decode(Bool.self, forKey: .promotionalOfferEligibility)) ?? true {
                try container.decodeIfPresent(String.self, forKey: .promotionalOfferId)
            } else {
                nil
            }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(vendorId, forKey: .vendorId)
        try container.encode(adaptyProductId, forKey: .adaptyProductId)
        try container.encodeIfPresent(promotionalOfferId, forKey: .promotionalOfferId)
        try container.encodeIfPresent(winBackOfferId, forKey: .winBackOfferId)
    }
}
