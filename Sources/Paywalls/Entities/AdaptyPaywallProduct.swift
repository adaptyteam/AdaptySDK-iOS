//
//  AdaptyPaywallProduct.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 20.10.2022.
//

import StoreKit

public struct AdaptyPaywallProduct: Sendable {
    package let adaptyProductId: String

    let underlying: AdaptyProduct

    public let subscriptionOffer: AdaptySubscriptionOffer.Available

    /// Same as `variationId` property of the parent AdaptyPaywall.
    public let variationId: String

    /// Same as `abTestName` property of the parent AdaptyPaywall.
    public let paywallABTestName: String

    /// Same as `name` property of the parent AdaptyPaywall.
    public let paywallName: String

    init(
        adaptyProductId: String,
        underlying: AdaptyProduct,
        subscriptionOffer: AdaptySubscriptionOffer.Available,
        variationId: String,
        paywallABTestName: String,
        paywallName: String
    ) {
        self.adaptyProductId = adaptyProductId
        self.underlying = underlying
        self.subscriptionOffer = subscriptionOffer
        self.variationId = variationId
        self.paywallABTestName = paywallABTestName
        self.paywallName = paywallName
    }
}

extension AdaptyPaywallProduct: AdaptyProduct {
    public var sk1Product: StoreKit.SKProduct? { underlying.sk1Product }

    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
    public var sk2Product: StoreKit.Product? { underlying.sk2Product }

    public var vendorProductId: String { underlying.vendorProductId }
    public var localizedDescription: String { underlying.localizedDescription }
    public var localizedTitle: String { underlying.localizedTitle }
    public var price: Decimal { underlying.price }
    public var currencyCode: String? { underlying.currencyCode }
    public var currencySymbol: String? { underlying.currencySymbol }
    public var regionCode: String? { underlying.regionCode }
    public var isFamilyShareable: Bool { underlying.isFamilyShareable }
    public var subscriptionPeriod: AdaptyProductSubscriptionPeriod? { underlying.subscriptionPeriod }
    public var subscriptionGroupIdentifier: String? { underlying.subscriptionGroupIdentifier }
    public var localizedPrice: String? { underlying.localizedPrice }
    public var localizedSubscriptionPeriod: String? { underlying.localizedSubscriptionPeriod }
}

extension AdaptyPaywallProduct: CustomStringConvertible {
    public var description: String {
        "(paywallName: \(paywallName), adaptyProductId: \(adaptyProductId), variationId: \(variationId), paywallABTestName: \(paywallABTestName), subscriptionOffer:\(subscriptionOffer) , product:\(underlying.description)"
    }
}

extension AdaptySubscriptionOffer {
    public enum Available: Sendable {
        case notDetermined
        case unavailable
        case available(AdaptySubscriptionOffer)
    }
}

extension AdaptySubscriptionOffer.Available: Encodable {
    enum CodingKeys: String, CodingKey {
        case determined
        case offer
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .notDetermined:
            try container.encode(false, forKey: .determined)
        case .unavailable:
            try container.encode(true, forKey: .determined)
        case let .available(offer):
            try container.encode(true, forKey: .determined)
            try container.encode(offer, forKey: .offer)
        }
    }
}

extension AdaptyPaywallProduct: Encodable {
    enum CodingKeys: String, CodingKey {
        case vendorProductId = "vendor_product_id"
        case adaptyProductId = "adapty_product_id"

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

    private struct SubscriptionDetail: Sendable, Encodable {
        let product: AdaptyPaywallProduct

        enum CodingKeys: String, CodingKey {
            case subscriptionGroupIdentifier = "subscription_group_identifier"
            case renewalType = "renewal_type"
            case subscriptionPeriod = "subscription_period"
            case localizedSubscriptionPeriod = "localized_subscription_period"
            ///            case introductoryOfferPhases = "introductory_offer_phases"
            case subscriptionOffer = "offer"
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encodeIfPresent(product.subscriptionGroupIdentifier, forKey: .subscriptionGroupIdentifier)
            try container.encode("autorenewable", forKey: .renewalType)
            try container.encodeIfPresent(product.subscriptionPeriod, forKey: .subscriptionPeriod)
            try container.encodeIfPresent(product.localizedSubscriptionPeriod, forKey: .localizedSubscriptionPeriod)
            try container.encode(product.subscriptionOffer, forKey: .subscriptionOffer)
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(vendorProductId, forKey: .vendorProductId)
        try container.encode(adaptyProductId, forKey: .adaptyProductId)

        try container.encode(variationId, forKey: .paywallVariationId)
        try container.encode(paywallABTestName, forKey: .paywallABTestName)
        try container.encode(paywallName, forKey: .paywallName)

        try container.encode(localizedDescription, forKey: .localizedDescription)
        try container.encode(localizedTitle, forKey: .localizedTitle)
        try container.encode(Price(from: self), forKey: .price)
        try container.encodeIfPresent(regionCode, forKey: .regionCode)
        try container.encode(isFamilyShareable, forKey: .isFamilyShareable)

        if underlying.subscriptionPeriod != nil {
            try container.encode(SubscriptionDetail(product: self), forKey: .subscriptionDetails)
        }
    }
}
