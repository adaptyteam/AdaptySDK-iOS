//
//  AdaptyDeferredProduct.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 20.10.2022.
//

import StoreKit

public final class AdaptyDeferredProduct: @unchecked Sendable {
    /// An identifier of a promotional offer, provided by Adapty for this specific user.
    public var promotionalOfferId: String? { payment.paymentDiscount?.identifier }

    let payment: SKPayment
    let underlying: AdaptySK1Product

    init(sk1Product: SK1Product, payment: SKPayment) {
        self.payment = payment
        self.underlying = AdaptySK1Product(skProduct: sk1Product)
    }
}

extension AdaptyDeferredProduct: AdaptyProduct {
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

extension AdaptyDeferredProduct: CustomStringConvertible {
    public var description: String {
        "(vendorProductId: \(vendorProductId)"
            + (promotionalOfferId.map { ", promotionalOfferId: \($0)" } ?? "")
            + ", product: \(underlying.description))"
    }
}
