//
//  AdaptyDeferredProduct.swift
//  Adapty
//
//  Created by Aleksei Valiano on 20.10.2022.
//

import StoreKit

public struct AdaptyDeferredProduct: AdaptyProduct {
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
            promotionalOfferId: promotionalOfferId,
            skProduct: skProduct
        )
    }
}
