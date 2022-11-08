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

    /// User's eligibility for your introductory offer. Check this property before displaying info about introductory offers (i.e. free trials).
    public let introductoryOfferEligibility: AdaptyEligibility

    /// User's eligibility for the promotional offers. Check this property before displaying info about promotional offers.
    public var promotionalOfferEligibility: Bool { promotionalOfferId != nil }

    let version: Int64

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
        "(vendorProductId: \(vendorProductId), introductoryOfferEligibility: \(introductoryOfferEligibility)"
            + (promotionalOfferId == nil ? "" : ", promotionalOfferId: \(promotionalOfferId!)")
            + ", variationId: \(variationId), paywallABTestName: \(paywallABTestName), paywallName: \(paywallName), skProduct: \(skProduct))"
    }
}

extension AdaptyPaywallProduct {
    init(paywall: AdaptyPaywall, product: BackendProduct, skProduct: SKProduct) {
        self.init(
            vendorProductId: product.vendorId,
            introductoryOfferEligibility: product.introductoryOfferEligibility,
            version: product.version,
            promotionalOfferId: !product.promotionalOfferEligibility ? nil : paywall.products.first(where: { $0.vendorId == product.vendorId })?.promotionalOfferId,
            variationId: paywall.variationId,
            paywallABTestName: paywall.abTestName,
            paywallName: paywall.name,
            skProduct: skProduct
        )
    }
}

extension AdaptyPaywallProduct: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: ProductCodingKeys.self)
        try container.encode(vendorProductId, forKey: .vendorProductId)
        try container.encode(introductoryOfferEligibility, forKey: .introductoryOfferEligibility)
        try container.encode(version, forKey: .version)

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
