//
//  AdaptyDeferredProduct.swift
//  Adapty
//
//  Created by Aleksei Valiano on 20.10.2022.
//

import StoreKit

public struct AdaptyDeferredProduct: AdaptyProduct {
    /// Unique identifier of a product from App Store Connect or Google Play Console.
    public let vendorProductId: String

    /// User's eligibility for the promotional offers. Check this property before displaying info about promotional offers.
    public var promotionalOfferEligibility: Bool { promotionalOfferId != nil }

    /// An identifier of a promotional offer, provided by Adapty for this specific user.
    public let promotionalOfferId: String?

    /// Underlying system representation of the product.
    public let skProduct: SKProduct
}

extension AdaptyDeferredProduct: CustomStringConvertible {
    public var description: String {
        "(vendorProductId: \(vendorProductId)"
            + (promotionalOfferId == nil ? "" : ", promotionalOfferId: \(promotionalOfferId!)")
            + ", skProduct: \(skProduct))"
    }
}

extension AdaptyDeferredProduct {
    init(skProduct: SKProduct, payment: SKPayment?) {
        let promotionalOfferId: String?
        if #available(iOS 12.2, macOS 10.14.4, *), let discountId = payment?.paymentDiscount?.identifier {
            promotionalOfferId = discountId
        } else {
            promotionalOfferId = nil
        }
        self.init(
            vendorProductId: skProduct.productIdentifier,
            promotionalOfferId: promotionalOfferId,
            skProduct: skProduct
        )
    }
}

extension AdaptyDeferredProduct: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: ProductCodingKeys.self)
        try container.encode(vendorProductId, forKey: .vendorProductId)

        try container.encodeIfPresent(promotionalOfferId, forKey: .promotionalOfferId)

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
