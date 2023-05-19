//
//  AdaptyPaywallProduct.swift
//  Adapty
//
//  Created by Aleksei Valiano on 20.10.2022.
//

import StoreKit

public struct AdaptyPaywallProduct: AdaptyProduct {
    /// Unique identifier of a product from App Store Connect or Google Play Console.
    public let vendorProductId: String

    /// User's eligibility for the promotional offers. Check this property before displaying info about promotional offers.
    public var promotionalOfferEligibility: Bool { promotionalOfferId != nil }

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
        "(vendorProductId: \(vendorProductId)"
            + (promotionalOfferId == nil ? "" : ", promotionalOfferId: \(promotionalOfferId!)")
            + ", variationId: \(variationId), paywallABTestName: \(paywallABTestName), paywallName: \(paywallName), skProduct: \(skProduct))"
    }
}

extension AdaptyPaywallProduct {
    init(paywall: AdaptyPaywall,
         productReference: AdaptyPaywall.ProductReference,
         skProduct: SKProduct) {
        self.init(
            vendorProductId: productReference.vendorId,
            promotionalOfferId: productReference.promotionalOfferId,
            variationId: paywall.variationId,
            paywallABTestName: paywall.abTestName,
            paywallName: paywall.name,
            skProduct: skProduct
        )
    }

    init?(paywall: AdaptyPaywall,
          skProduct: SKProduct) {
        let vendorId = skProduct.productIdentifier
        guard let reference = paywall.products.first(where: { $0.vendorId == vendorId }) else {
            return nil
        }

        self.init(paywall: paywall, productReference: reference, skProduct: skProduct)
    }
}

extension AdaptyPaywallProduct: Encodable {
    struct PrivateObject: Decodable {
        let vendorProductId: String
        let promotionalOfferId: String?
        let variationId: String
        let paywallABTestName: String
        let paywallName: String

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: ProductCodingKeys.self)
            vendorProductId = try container.decode(String.self, forKey: .vendorProductId)
            promotionalOfferId = try container.decodeIfPresent(String.self, forKey: .promotionalOfferId)
            variationId = try container.decode(String.self, forKey: .variationId)
            paywallABTestName = try container.decode(String.self, forKey: .paywallABTestName)
            paywallName = try container.decode(String.self, forKey: .paywallName)
        }
    }

    init(from object: PrivateObject, skProduct: SKProduct) {
        self.init(
            vendorProductId: object.vendorProductId,
            promotionalOfferId: object.promotionalOfferId,
            variationId: object.variationId,
            paywallABTestName: object.paywallABTestName,
            paywallName: object.paywallName,
            skProduct: skProduct
        )
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: ProductCodingKeys.self)
        try container.encode(vendorProductId, forKey: .vendorProductId)

        try container.encodeIfPresent(promotionalOfferId, forKey: .promotionalOfferId)
        try container.encode(variationId, forKey: .variationId)
        try container.encode(paywallABTestName, forKey: .paywallABTestName)
        try container.encode(paywallName, forKey: .paywallName)

        try container.encode(localizedDescription, forKey: .localizedDescription)
        try container.encode(localizedTitle, forKey: .localizedTitle)
        try container.encode(price, forKey: .price)
        try container.encodeIfPresent(currencyCode, forKey: .currencyCode)
        try container.encodeIfPresent(currencySymbol, forKey: .currencySymbol)
        try container.encodeIfPresent(regionCode, forKey: .regionCode)
        try container.encode(isFamilyShareable, forKey: .isFamilyShareable)
        try container.encodeIfPresent(subscriptionPeriod, forKey: .subscriptionPeriod)
        try container.encodeIfPresent(introductoryDiscount, forKey: .introductoryDiscount)
        try container.encodeIfPresent(subscriptionGroupIdentifier, forKey: .subscriptionGroupIdentifier)
        try container.encode(discounts, forKey: .discounts)
        try container.encodeIfPresent(localizedPrice, forKey: .localizedPrice)
        try container.encodeIfPresent(localizedSubscriptionPeriod, forKey: .localizedSubscriptionPeriod)
    }
}
