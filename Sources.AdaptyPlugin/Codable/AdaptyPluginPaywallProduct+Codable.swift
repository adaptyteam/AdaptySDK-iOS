//
//  AdaptyPluginPaywallProduct+Codable.swift
//  AdaptyPlugin
//
//  Created by Aleksei Valiano on 11.11.2024.
//

import Adapty
import Foundation

extension Request {
    struct AdaptyPluginPaywallProduct: Decodable {
        let vendorProductId: String
        let adaptyProductId: String
        let paywallProductIndex: Int
        let subscriptionOfferIdentifier: AdaptySubscriptionOffer.Identifier?
        let variationId: String
        let paywallABTestName: String
        let paywallName: String
        let webPaywallBaseUrl: URL?

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            vendorProductId = try container.decode(String.self, forKey: .vendorProductId)
            adaptyProductId = try container.decode(String.self, forKey: .adaptyProductId)
            paywallProductIndex = try container.decode(Int.self, forKey: .paywallProductIndex)
            subscriptionOfferIdentifier = try container.decodeIfPresent(AdaptySubscriptionOffer.Identifier.self, forKey: .subscriptionOfferIdentifier)
            variationId = try container.decode(String.self, forKey: .paywallVariationId)
            paywallABTestName = try container.decode(String.self, forKey: .paywallABTestName)
            paywallName = try container.decode(String.self, forKey: .paywallName)
            webPaywallBaseUrl = try container.decodeIfPresent(URL.self, forKey: .webPaywallBaseUrl)
        }
    }
}

private enum CodingKeys: String, CodingKey {
    case vendorProductId = "vendor_product_id"
    case adaptyProductId = "adapty_product_id"
    case paywallProductIndex = "paywall_product_index"
    case paywallVariationId = "paywall_variation_id"
    case paywallABTestName = "paywall_ab_test_name"
    case paywallName = "paywall_name"
    case webPaywallBaseUrl = "web_purchase_url"
    case subscriptionOfferIdentifier = "subscription_offer_identifier"
    case subscription
    case localizedDescription = "localized_description"
    case localizedTitle = "localized_title"
    case price
    case regionCode = "region_code"
    case isFamilyShareable = "is_family_shareable"
}

extension Response {
    struct AdaptyPluginPaywallProduct: Encodable {
        let wrapped: AdaptyPaywallProduct

        init(_ wrapped: AdaptyPaywallProduct) {
            self.wrapped = wrapped
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(wrapped.vendorProductId, forKey: .vendorProductId)
            try container.encode(wrapped.adaptyProductId, forKey: .adaptyProductId)
            try container.encode(wrapped.paywallProductIndex, forKey: .paywallProductIndex)
            try container.encode(wrapped.variationId, forKey: .paywallVariationId)
            try container.encode(wrapped.paywallABTestName, forKey: .paywallABTestName)
            try container.encode(wrapped.paywallName, forKey: .paywallName)
            try container.encodeIfPresent((wrapped as? WebPaywallURLProviding)?.webPaywallBaseUrl, forKey: .webPaywallBaseUrl)
            try container.encode(wrapped.localizedDescription, forKey: .localizedDescription)
            try container.encode(wrapped.localizedTitle, forKey: .localizedTitle)
            try container.encode(wrapped.isFamilyShareable, forKey: .isFamilyShareable)
            try container.encodeIfPresent(wrapped.regionCode, forKey: .regionCode)
            try container.encode(Price(from: wrapped), forKey: .price)
            try container.encodeIfPresent(Subscription(product: wrapped), forKey: .subscription)
        }
    }
}

public extension AdaptyPaywallProduct {
    var asAdaptyJsonData: AdaptyJsonData {
        get throws {
            try AdaptyPlugin.encoder.encode(
                Response.AdaptyPluginPaywallProduct(self)
            )
        }
    }
}

private struct Subscription: Sendable, Encodable {
    let groupIdentifier: String
    let period: AdaptySubscriptionPeriod
    let localizedPeriod: String?
    let offer: AdaptySubscriptionOffer?

    init?(product: AdaptyPaywallProduct) {
        guard let groupIdentifier = product.subscriptionGroupIdentifier,
              let period = product.subscriptionPeriod
        else { return nil }

        self.groupIdentifier = groupIdentifier
        self.period = period
        localizedPeriod = product.localizedSubscriptionPeriod
        offer = product.subscriptionOffer
    }

    enum CodingKeys: String, CodingKey {
        case groupIdentifier = "group_identifier"
        case period
        case localizedPeriod = "localized_period"
        case offer
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(groupIdentifier, forKey: .groupIdentifier)
        try container.encode(period, forKey: .period)
        try container.encodeIfPresent(localizedPeriod, forKey: .localizedPeriod)
        try container.encode(offer, forKey: .offer)
    }
}
