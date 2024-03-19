//
//  AdaptyPaywallProduct.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 20.10.2022.
//

import StoreKit

public struct AdaptyPaywallProduct: AdaptyProduct {
    /// Unique identifier of a product from App Store Connect or Google Play Console.
    public let vendorProductId: String

    let adaptyProductId: String

    /// An identifier of a promotional offer, provided by Adapty for this specific user.
    public let promotionalOfferId: String?

    /// Same as `variationId` property of the parent AdaptyPaywall.
    public let variationId: String

    /// Same as `abTestName` property of the parent AdaptyPaywall.
    public let paywallABTestName: String

    /// Same as `name` property of the parent AdaptyPaywall.
    public let paywallName: String

    /// Underlying system representation of the product.
    public let skProduct: SKProduct
}

extension AdaptyPaywallProduct: CustomStringConvertible {
    public var description: String {
        "(vendorProductId: \(vendorProductId), adaptyProductId: \(adaptyProductId)"
            + (promotionalOfferId.map { ", promotionalOfferId: \($0)" } ?? "")
            + ", variationId: \(variationId), paywallABTestName: \(paywallABTestName), paywallName: \(paywallName), skProduct: \(skProduct))"
    }
}

extension AdaptyPaywallProduct {
    init(
        paywall: AdaptyPaywall,
        productReference: AdaptyPaywall.ProductReference,
        sk1Product: SK1Product
    ) {
        self.init(
            vendorProductId: productReference.vendorId,
            adaptyProductId: productReference.adaptyProductId,
            promotionalOfferId: productReference.promotionalOfferId,
            variationId: paywall.variationId,
            paywallABTestName: paywall.abTestName,
            paywallName: paywall.name,
            skProduct: sk1Product
        )
    }

    init?(paywall: AdaptyPaywall, sk1Product: SK1Product) {
        let vendorId = sk1Product.productIdentifier
        guard let reference = paywall.products.first(where: { $0.vendorId == vendorId }) else {
            return nil
        }

        self.init(paywall: paywall, productReference: reference, sk1Product: sk1Product)
    }
}

extension AdaptyPaywallProduct: Encodable {
    struct PrivateObject: Decodable {
        let vendorProductId: String
        let adaptyProductId: String
        let promotionalOfferId: String?
        let variationId: String
        let paywallABTestName: String
        let paywallName: String

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: ProductCodingKeys.self)
            vendorProductId = try container.decode(String.self, forKey: .vendorProductId)
            adaptyProductId = try container.decode(String.self, forKey: .adaptyProductId)
            promotionalOfferId = try container.decodeIfPresent(String.self, forKey: .promotionalOfferId)
            variationId = try container.decode(String.self, forKey: .paywallVariationId)
            paywallABTestName = try container.decode(String.self, forKey: .paywallABTestName)
            paywallName = try container.decode(String.self, forKey: .paywallName)
        }
    }

    private enum ProductCodingKeys: String, CodingKey {
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

    init(from object: PrivateObject, sk1Product: SK1Product) {
        self.init(
            vendorProductId: object.vendorProductId,
            adaptyProductId: object.adaptyProductId,
            promotionalOfferId: object.promotionalOfferId,
            variationId: object.variationId,
            paywallABTestName: object.paywallABTestName,
            paywallName: object.paywallName,
            skProduct: sk1Product
        )
    }

    private struct SubscriptionDetail: Encodable {
        let product: AdaptyPaywallProduct

        enum CodingKeys: String, CodingKey {
            case subscriptionGroupIdentifier = "subscription_group_identifier"
            case renewalType = "renewal_type"
            case subscriptionPeriod = "subscription_period"
            case localizedSubscriptionPeriod = "localized_subscription_period"
            case introductoryOfferPhases = "introductory_offer_phases"
            case promotionalOffer = "promotional_offer"
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encodeIfPresent(product.subscriptionGroupIdentifier, forKey: .subscriptionGroupIdentifier)
            try container.encode("autorenewable", forKey: .renewalType)
            try container.encodeIfPresent(product.subscriptionPeriod, forKey: .subscriptionPeriod)
            try container.encodeIfPresent(product.localizedSubscriptionPeriod, forKey: .localizedSubscriptionPeriod)

            if let id = product.promotionalOfferId,
               let discount = product.discount(byIdentifier: id) {
                try container.encode(discount, forKey: .promotionalOffer)
            }

            if let discount = product.introductoryDiscount {
                try container.encode([discount], forKey: .introductoryOfferPhases)
            }
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: ProductCodingKeys.self)
        try container.encode(vendorProductId, forKey: .vendorProductId)
        try container.encode(adaptyProductId, forKey: .adaptyProductId)

        try container.encode(variationId, forKey: .paywallVariationId)
        try container.encode(paywallABTestName, forKey: .paywallABTestName)
        try container.encode(paywallName, forKey: .paywallName)

        try container.encode(localizedDescription, forKey: .localizedDescription)
        try container.encode(localizedTitle, forKey: .localizedTitle)
        try container.encode(priceValue, forKey: .price)
        try container.encodeIfPresent(regionCode, forKey: .regionCode)
        try container.encode(isFamilyShareable, forKey: .isFamilyShareable)

        if skProduct.subscriptionPeriod != nil {
            try container.encode(SubscriptionDetail(product: self), forKey: .subscriptionDetails)
        }
    }
}
