//
//  AdaptyPluginPaywallProduct+Codable.swift
//  Adapty
//
//  Created by Aleksei Valiano on 11.11.2024.
//

import Adapty
import Foundation

extension Request {
    struct AdaptyPluginPaywallProduct: Decodable {
        let vendorProductId: String
        let adaptyProductId: String
        let promotionalOfferId: String?
        let variationId: String
        let paywallABTestName: String
        let paywallName: String

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            vendorProductId = try container.decode(String.self, forKey: .vendorProductId)
            adaptyProductId = try container.decode(String.self, forKey: .adaptyProductId)
            promotionalOfferId = try container.decodeIfPresent(String.self, forKey: .promotionalOfferId)
            variationId = try container.decode(String.self, forKey: .paywallVariationId)
            paywallABTestName = try container.decode(String.self, forKey: .paywallABTestName)
            paywallName = try container.decode(String.self, forKey: .paywallName)
        }
    }
}

private enum CodingKeys: String, CodingKey {
    case vendorProductId = "vendor_product_id"
    case adaptyProductId = "adapty_product_id"

    case promotionalOfferId = "promotional_offer_id"
    case paywallVariationId = "paywall_variation_id"
    case paywallABTestName = "paywall_ab_test_name"
    case paywallName = "paywall_name"

    case subscriptionDetails = "subscription_details"

    case localizedDescription = "localized_description"
    case localizedTitle = "localized_title"
    case price
    case regionCode = "region_code"
    case isFamilyShareable = "is_family_shareable"
}

extension Response {
    struct AdaptyPluginPaywallProduct: Encodable {
        let adaptyPaywallProduct: AdaptyPaywallProduct
        init(_ adaptyPaywallProduct: AdaptyPaywallProduct) throws {
            self.adaptyPaywallProduct = adaptyPaywallProduct
        }

        func encode(to encoder: any Encoder) throws {}
    }
}
