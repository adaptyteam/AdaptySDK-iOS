//
//  AdaptyFlow.ProductReference.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 11.05.2023
//

import Foundation

extension AdaptyFlow {
    struct ProductReference: Sendable, Hashable {
        let paywallProductIndex: Int
        let flowProductId: String?
        let adaptyProductId: String
        let productInfo: BackendProductInfo
        let promotionalOfferId: String?
        let winBackOfferId: String?
    }
}

extension AdaptyFlow.ProductReference: CustomStringConvertible {
    public var description: String {
        "(vendorId: \(productInfo.vendorId), adaptyProductId: \(adaptyProductId), promotionalOfferId: \(promotionalOfferId ?? "nil")))"
    }
}

extension AdaptyFlow.ProductReference: Encodable {
    enum CodingKeys: String, CodingKey {
        case flowProductId = "flow_product_id"
        case vendorId = "vendor_product_id"
        case adaptyProductId = "adapty_product_id"
        case promotionalOfferEligibility = "promotional_offer_eligibility"
        case promotionalOfferId = "promotional_offer_id"
        case winBackOfferId = "win_back_offer_id"
        case accessLevelId = "access_level_id"
        case backendProductPeriod = "product_type"
    }

    init(from container: KeyedDecodingContainer<CodingKeys>, index: Int) throws {
        self.flowProductId = try container.decodeIfPresent(String.self, forKey: .flowProductId)
        self.paywallProductIndex = index
        self.winBackOfferId = try container.decodeIfPresent(String.self, forKey: .winBackOfferId)
        self.adaptyProductId = try container.decode(String.self, forKey: .adaptyProductId)
        self.productInfo = try BackendProductInfo(
            vendorId: container.decode(String.self, forKey: .vendorId),
            accessLevelId: container.decode(String.self, forKey: .accessLevelId),
            period: container.decode(BackendProductInfo.Period.self, forKey: .backendProductPeriod)
        )
        let promotionalOfferEligibility = try container.decode(Bool.self, forKey: .promotionalOfferEligibility)
        self.promotionalOfferId =
            if promotionalOfferEligibility {
                try container.decodeIfPresent(String.self, forKey: .promotionalOfferId)
            } else {
                nil
            }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(flowProductId, forKey: .flowProductId)
        try container.encode(productInfo.vendorId, forKey: .vendorId)
        try container.encode(adaptyProductId, forKey: .adaptyProductId)
        try container.encodeIfPresent(promotionalOfferId, forKey: .promotionalOfferId)
        try container.encodeIfPresent(winBackOfferId, forKey: .winBackOfferId)
        try container.encode(productInfo.accessLevelId, forKey: .accessLevelId)
        try container.encode(productInfo.period, forKey: .backendProductPeriod)
    }
}
