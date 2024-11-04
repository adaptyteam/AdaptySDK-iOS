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
    let skProduct: SK1Product

    init(sk1Product: SK1Product, payment: SKPayment) {
        self.payment = payment
        self.skProduct = sk1Product
    }
}

extension AdaptyDeferredProduct: AdaptySK1Product {}

extension AdaptyDeferredProduct: CustomStringConvertible {
    public var description: String {
        "(vendorProductId: \(vendorProductId)"
            + (promotionalOfferId.map { ", promotionalOfferId: \($0)" } ?? "")
            + ", skProduct: \(skProduct))"
    }
}
