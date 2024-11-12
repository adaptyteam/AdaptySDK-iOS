//
//  AdaptyPaywallProduct.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 20.10.2022.
//

import StoreKit

public protocol AdaptyPaywallProductWithoutDeterminingOffer: AdaptyProduct {

    var adaptyProductId: String { get }
    
    /// Same as `variationId` property of the parent AdaptyPaywall.
    var variationId: String { get }

    /// Same as `abTestName` property of the parent AdaptyPaywall.
    var paywallABTestName: String { get }

    /// Same as `name` property of the parent AdaptyPaywall.
    var paywallName: String { get }
}

public protocol AdaptyPaywallProduct: AdaptyPaywallProductWithoutDeterminingOffer {
    var subscriptionOffer: AdaptySubscriptionOffer? { get }
}


//
//extension AdaptyPaywallProduct: Encodable {
//    enum CodingKeys: String, CodingKey {
//        case vendorProductId = "vendor_product_id"
//        case adaptyProductId = "adapty_product_id"
//
//        case paywallVariationId = "paywall_variation_id"
//        case paywallABTestName = "paywall_ab_test_name"
//        case paywallName = "paywall_name"
//
//        case subscriptionDetails = "subscription_details"
//
//        case localizedDescription = "localized_description"
//        case localizedTitle = "localized_title"
//        case price
//        case regionCode = "region_code"
//        case isFamilyShareable = "is_family_shareable"
//    }
//
//    private struct SubscriptionDetail: Sendable, Encodable {
//        let product: AdaptyPaywallProduct
//
//        enum CodingKeys: String, CodingKey {
//            case subscriptionGroupIdentifier = "subscription_group_identifier"
//            case renewalType = "renewal_type"
//            case subscriptionPeriod = "subscription_period"
//            case localizedSubscriptionPeriod = "localized_subscription_period"
//            ///            case introductoryOfferPhases = "introductory_offer_phases"
//            case subscriptionOffer = "offer"
//        }
//
//        func encode(to encoder: Encoder) throws {
//            var container = encoder.container(keyedBy: CodingKeys.self)
//            try container.encodeIfPresent(product.subscriptionGroupIdentifier, forKey: .subscriptionGroupIdentifier)
//            try container.encode("autorenewable", forKey: .renewalType)
//            try container.encodeIfPresent(product.subscriptionPeriod, forKey: .subscriptionPeriod)
//            try container.encodeIfPresent(product.localizedSubscriptionPeriod, forKey: .localizedSubscriptionPeriod)
//            try container.encode(product.subscriptionOffer, forKey: .subscriptionOffer)
//        }
//    }
//
//    public func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: CodingKeys.self)
//        try container.encode(vendorProductId, forKey: .vendorProductId)
//        try container.encode(adaptyProductId, forKey: .adaptyProductId)
//
//        try container.encode(variationId, forKey: .paywallVariationId)
//        try container.encode(paywallABTestName, forKey: .paywallABTestName)
//        try container.encode(paywallName, forKey: .paywallName)
//
//        try container.encode(localizedDescription, forKey: .localizedDescription)
//        try container.encode(localizedTitle, forKey: .localizedTitle)
//        try container.encode(Price(from: self), forKey: .price)
//        try container.encodeIfPresent(regionCode, forKey: .regionCode)
//        try container.encode(isFamilyShareable, forKey: .isFamilyShareable)
//
//        if underlying.subscriptionPeriod != nil {
//            try container.encode(SubscriptionDetail(product: self), forKey: .subscriptionDetails)
//        }
//    }
//}
