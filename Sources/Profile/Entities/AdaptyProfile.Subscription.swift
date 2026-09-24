//
//  AdaptyProfile.Subscription.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 24.09.2022.
//

import Foundation

public extension AdaptyProfile {
    /// Information about the user's subscription.
    struct Subscription: Sendable, Hashable {
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
        public let vendorTransactionId: String

        /// An original transaction id of the purchase in a store that unlocked this subscription. For auto-renewable subscription, this will be an id of the first transaction in this subscription.
        public let vendorOriginalTransactionId: String

        /// True if the subscription is active
        public let isActive: Bool

        /// True if the subscription is active for a lifetime (no expiration date)
        public let isLifetime: Bool

        /// Time when the subscription was activated.
        public let activatedAt: Date

        /// Time when the subscription was renewed. It can be `nil` if the purchase was first in chain or it is non-renewing subscription.
        public let renewedAt: Date?

        /// Time when the access level will expire (could be in the past and could be `nil` for lifetime access).
        public let expiresAt: Date?

        /// Time when the subscription has started (could be in the future).
        public let startsAt: Date?

        /// Time when the auto-renewable subscription was cancelled. Subscription can still be active, it means that auto-renewal is turned off. Would be `nil` if a user reactivates the subscription.
        public let unsubscribedAt: Date?

        /// Time when a billing issue was detected. Subscription can still be active.
        public let billingIssueDetectedAt: Date?

        /// Whether the auto-renewable subscription is in a grace period.
        public let isInGracePeriod: Bool

        /// `true` if the product was purchased in a sandbox environment.
        public let isSandbox: Bool

        /// `true` if the purchase was refunded.
        public let isRefund: Bool

        /// `true` if the auto-renewable subscription is set to renew
        public let willRenew: Bool

        /// A type of an active introductory offer. If the value is not null, it means that the offer was applied during the current subscription period.
        ///
        /// Possible values:
        /// - `free_trial`
        /// - `pay_as_you_go`
        /// - `pay_up_front`
        public let activeIntroductoryOfferType: String?

        /// A type of an active promotional offer. If the value is not null, it means that the offer was applied during the current subscription period.
        ///
        /// Possible values:
        /// - `free_trial`
        /// - `pay_as_you_go`
        /// - `pay_up_front`
        public let activePromotionalOfferType: String?

        /// An id of active promotional offer.
        public let activePromotionalOfferId: String?

        public let offerId: String?

        public let billingPlan: AdaptySubscriptionBillingPlan

        public let commitmentInfo: AdaptyProfile.SubscriptionCommitmentInfo?

        /// A reason why a subscription was cancelled.
        ///
        /// Possible values:
        /// - `voluntarily_cancelled`
        /// - `billing_error`
        /// - `price_increase`
        /// - `product_was_not_available`
        /// - `refund`
        /// - `upgraded`
        /// - `unknown`
        public let cancellationReason: String?
    }
}

extension AdaptyProfile.Subscription: CustomStringConvertible {
    public var description: String {
        "(isActive: \(isActive), vendorProductId: \(vendorProductId), store: \(store), activatedAt: \(activatedAt), "
            + (renewedAt.map { "renewedAt: \($0), " } ?? "")
            + (expiresAt.map { "expiresAt: \($0), " } ?? "")
            + (startsAt.map { "startsAt: \($0), " } ?? "")
            + "isLifetime: \(isLifetime), "
        + "billingPlan: \(billingPlan.rawValue), "
            + (commitmentInfo.map { "commitmentInfo: \($0), " } ?? "")
            + (activeIntroductoryOfferType.map { "activeIntroductoryOfferType: \($0), " } ?? "")
            + (activePromotionalOfferType.map { "activePromotionalOfferType: \($0), " } ?? "")
            + (activePromotionalOfferId.map { "activePromotionalOfferId: \($0), " } ?? "")
            + (offerId.map { "offerId: \($0), " } ?? "")
            + "willRenew: \(willRenew), isInGracePeriod: \(isInGracePeriod), "
            + (unsubscribedAt.map { "unsubscribedAt: \($0), " } ?? "")
            + (billingIssueDetectedAt.map { "billingIssueDetectedAt: \($0), " } ?? "")
            + "isSandbox: \(isSandbox), vendorTransactionId: \(vendorTransactionId), vendorOriginalTransactionId: \(vendorOriginalTransactionId), "
            + (cancellationReason.map { "cancellationReason: \($0), " } ?? "")
            + "isRefund: \(isRefund))"
    }
}

extension AdaptyProfile.Subscription: Codable {
    enum CodingKeys: String, CodingKey {
        case isActive = "is_active"
        case vendorProductId = "vendor_product_id"
        case vendorTransactionId = "vendor_transaction_id"
        case vendorOriginalTransactionId = "vendor_original_transaction_id"
        case store
        case activatedAt = "activated_at"
        case renewedAt = "renewed_at"
        case expiresAt = "expires_at"
        case isLifetime = "is_lifetime"
        case activeIntroductoryOfferType = "active_introductory_offer_type"
        case activePromotionalOfferType = "active_promotional_offer_type"
        case activePromotionalOfferId = "active_promotional_offer_id"
        case offerId = "offer_id"
        case willRenew = "will_renew"
        case isInGracePeriod = "is_in_grace_period"
        case unsubscribedAt = "unsubscribed_at"
        case billingIssueDetectedAt = "billing_issue_detected_at"
        case startsAt = "starts_at"
        case cancellationReason = "cancellation_reason"
        case isRefund = "is_refund"
        case isSandbox = "is_sandbox"
        case billingPlan = "billing_plan_id"
        case commitmentInfo = "commitment"
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            store: container.decode(String.self, forKey: .store),
            vendorProductId: container.decode(String.self, forKey: .vendorProductId),
            vendorTransactionId: container.decode(String.self, forKey: .vendorTransactionId),
            vendorOriginalTransactionId: container.decode(String.self, forKey: .vendorOriginalTransactionId),
            isActive: container.decode(Bool.self, forKey: .isActive),
            isLifetime: container.decode(Bool.self, forKey: .isLifetime),
            activatedAt: container.decode(Date.self, forKey: .activatedAt),
            renewedAt: container.decodeIfPresent(Date.self, forKey: .renewedAt),
            expiresAt: container.decodeIfPresent(Date.self, forKey: .expiresAt),
            startsAt: container.decodeIfPresent(Date.self, forKey: .startsAt),
            unsubscribedAt: container.decodeIfPresent(Date.self, forKey: .unsubscribedAt),
            billingIssueDetectedAt: container.decodeIfPresent(Date.self, forKey: .billingIssueDetectedAt),
            isInGracePeriod: container.decode(Bool.self, forKey: .isInGracePeriod),
            isSandbox: container.decode(Bool.self, forKey: .isSandbox),
            isRefund: container.decode(Bool.self, forKey: .isRefund),
            willRenew: container.decode(Bool.self, forKey: .willRenew),
            activeIntroductoryOfferType: container.decodeIfPresent(String.self, forKey: .activeIntroductoryOfferType),
            activePromotionalOfferType: container.decodeIfPresent(String.self, forKey: .activePromotionalOfferType),
            activePromotionalOfferId: container.decodeIfPresent(String.self, forKey: .activePromotionalOfferId),
            offerId: container.decodeIfPresent(String.self, forKey: .offerId),
            billingPlan: container.decodeIfPresent(AdaptySubscriptionBillingPlan.self, forKey: .billingPlan) ?? .upFront,
            commitmentInfo: container.decodeIfPresent(AdaptyProfile.SubscriptionCommitmentInfo.self, forKey: .commitmentInfo),
            cancellationReason: container.decodeIfPresent(String.self, forKey: .cancellationReason)
        )
    }
}
