//
//    AdaptyProfile.NonSubscription.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 24.09.2022.
//

import Foundation

extension AdaptyProfile {
    public struct NonSubscription {
        /// An identifier of the purchase in Adapty. You can use it to ensure that you've already processed this purchase (for example tracking one time products).
        public let purchaseId: String

        /// A store of the purchase.
        ///
        /// Possible values:
        /// - `app_store`
        /// - `play_store`
        /// - `adapty`
        public let store: String

        /// An identifier of a product in a store that unlocked this subscription.
        public let vendorProductId: String

        /// A transaction id of a purchase in a store that unlocked this subscription.
        public let vendorTransactionId: String?

        /// Date when the product was purchased.
        public let purchasedAt: Date

        /// `true` if the product was purchased in a sandbox environment.
        public let isSandbox: Bool

        /// `true` if the purchase was refunded.
        public let isRefund: Bool

        /// `true` if the product is consumable (should only be processed once).
        public let isConsumable: Bool

        @available(*, deprecated, renamed: "isConsumable")
        public var isOneTime: Bool { isConsumable }
    }
}

extension AdaptyProfile.NonSubscription: Equatable {}

extension AdaptyProfile.NonSubscription: CustomStringConvertible {
    public var description: String {
        "(purchaseId: \(purchaseId), vendorProductId: \(vendorProductId), store: \(store), purchasedAt: \(purchasedAt), isConsumable: \(isConsumable), isSandbox: \(isSandbox), "
            + (vendorTransactionId.map { "vendorTransactionId: \($0), " } ?? "")
            + "isRefund: \(isRefund))"
    }
}

extension AdaptyProfile.NonSubscription: Codable {
    enum CodingKeys: String, CodingKey {
        case purchaseId = "purchase_id"
        case store
        case vendorProductId = "vendor_product_id"
        case vendorTransactionId = "vendor_transaction_id"
        case purchasedAt = "purchased_at"
        case isSandbox = "is_sandbox"
        case isRefund = "is_refund"
        case isConsumable = "is_consumable"
    }
}
