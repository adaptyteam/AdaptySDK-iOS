//
//  AdaptyFlowPaywall.ProductReference.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 11.05.2023
//

import Foundation

extension AdaptyFlowPaywall {
    struct ProductReference: Sendable, Hashable {
        let paywallProductIndex: Int
        let flowProductId: String?
        let adaptyProductId: String
        let productInfo: BackendProductInfo
        let pricingTerms: [ProducPricingTerms]
    }
}

extension AdaptyFlowPaywall.ProductReference: CustomStringConvertible {
    var description: String {
        "(vendorId: \(productInfo.vendorId), adaptyProductId: \(adaptyProductId), pricingTerms: \(pricingTerms)))"
    }
}

extension AdaptyFlowPaywall.ProductReference: Encodable {
    enum CodingKeys: String, CodingKey {
        case flowProductId = "flow_product_id"
        case vendorId = "vendor_product_id"
        case adaptyProductId = "adapty_product_id"
        case accessLevelId = "access_level_id"
        case backendProductPeriod = "product_type"
        case pricingTerms = "pricing_terms"

        // legacy properties:
        case promotionalOfferEligibility = "promotional_offer_eligibility"
        case promotionalOfferId = "promotional_offer_id"
        case winBackOfferId = "win_back_offer_id"
    }

    init(from container: KeyedDecodingContainer<CodingKeys>, index: Int) throws {
        flowProductId = try container.decodeIfPresent(String.self, forKey: .flowProductId)
        paywallProductIndex = index
        adaptyProductId = try container.decode(String.self, forKey: .adaptyProductId)
        productInfo = try BackendProductInfo(
            vendorId: container.decode(String.self, forKey: .vendorId),
            accessLevelId: container.decode(String.self, forKey: .accessLevelId),
            period: container.decode(BackendProductInfo.Period.self, forKey: .backendProductPeriod)
        )

        let legacyTerm = try AdaptyFlowPaywall.ProducPricingTerms.legacyDecoding(from: container)

        if let pricingTerms = try container.decodeIfPresent([AdaptyFlowPaywall.ProducPricingTerms].self, forKey: .pricingTerms), let last = pricingTerms.last {
            if last == legacyTerm || (last.billingPlan == .upFront && legacyTerm == .default) {
                self.pricingTerms = pricingTerms
            } else {
                self.pricingTerms = pricingTerms + [legacyTerm]
            }
        } else {
            self.pricingTerms = [legacyTerm]
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(flowProductId, forKey: .flowProductId)
        try container.encode(productInfo.vendorId, forKey: .vendorId)
        try container.encode(adaptyProductId, forKey: .adaptyProductId)
        try container.encode(productInfo.accessLevelId, forKey: .accessLevelId)
        try container.encode(productInfo.period, forKey: .backendProductPeriod)
        if pricingTerms.isNotEmpty {
            try container.encode(pricingTerms, forKey: .pricingTerms)
        }
    }
}

private extension AdaptyFlowPaywall.ProducPricingTerms {
    static func legacyDecoding(from container: KeyedDecodingContainer<AdaptyFlowPaywall.ProductReference.CodingKeys>) throws -> Self {
        let promotionalOfferEligibility = try container.decodeIfPresent(Bool.self, forKey: .promotionalOfferEligibility) ?? true
        let promotionalOfferId: String? =
            if promotionalOfferEligibility {
                try container.decodeIfPresent(String.self, forKey: .promotionalOfferId)
            } else {
                nil
            }

        let item = Self(
            billingPlan: .upFront,
            promotionalOfferId: promotionalOfferId,
            winBackOfferId: try container.decodeIfPresent(String.self, forKey: .winBackOfferId)
        )

        return item
    }
}
