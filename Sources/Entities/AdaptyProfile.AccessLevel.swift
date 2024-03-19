//
//  AdaptyProfile.AccessLevel.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 24.09.2022.
//

import Foundation

extension AdaptyProfile {
    public struct AccessLevel {
        /// Unique identifier of the access level configured by you in Adapty Dashboard.
        public let id: String

        /// `true` if this access level is active. Generally, you can check this property to determine wether a user has an access to premium features.
        public let isActive: Bool

        /// An identifier of a product in a store that unlocked this access level.
        public let vendorProductId: String

        /// A store of the purchase that unlocked this access level.
        ///
        /// Possible values:
        /// - `app_store`
        /// - `play_store`
        /// - `adapty`
        public let store: String

        /// Time when this access level was activated.
        public let activatedAt: Date

        /// Time when the access level was renewed. It can be `nil` if the purchase was first in chain or it is non-renewing subscription / non-consumable (e.g. lifetime)
        public let renewedAt: Date?

        /// Time when the access level will expire (could be in the past and could be `nil` for lifetime access).
        public let expiresAt: Date?

        /// `true` if this access level is active for a lifetime (no expiration date).
        public let isLifetime: Bool

        /// A type of an active introductory offer. If the value is not `nil`, it means that the offer was applied during the current subscription period.
        ///
        /// Possible values:
        /// - `free_trial`
        /// - `pay_as_you_go`
        /// - `pay_up_front`
        public let activeIntroductoryOfferType: String?

        ///  A type of an active promotional offer. If the value is not `nil`, it means that the offer was applied during the current subscription period.
        ///
        /// Possible values:
        /// - `free_trial`
        /// - `pay_as_you_go`
        /// - `pay_up_front`
        public let activePromotionalOfferType: String?

        /// An id of active promotional offer in case the purchase was made with iOS.
        public let activePromotionalOfferId: String?

        /// An id of active offer in case the purchase was made with Android.
        public let offerId: String?

        /// `true` if this auto-renewable subscription is set to renew.
        public let willRenew: Bool

        /// `true` if this auto-renewable subscription is in the grace period.
        public let isInGracePeriod: Bool

        /// Time when the auto-renewable subscription was cancelled. Subscription can still be active, it just means that auto-renewal turned off. Will be set to `nil` if the user reactivates the subscription.
        public let unsubscribedAt: Date?

        /// Time when billing issue was detected. Subscription can still be active. Would be set to null if a charge is made.
        public let billingIssueDetectedAt: Date?

        /// Time when this access level has started (could be in the future).
        public let startsAt: Date?

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

        /// `true` if this purchase was refunded
        public let isRefund: Bool
    }
}

extension AdaptyProfile.AccessLevel: Equatable {}

extension AdaptyProfile.AccessLevel: CustomStringConvertible {
    public var description: String {
        "(id: \(id), isActive: \(isActive), vendorProductId: \(vendorProductId), store: \(store), activatedAt: \(activatedAt), "
            + (renewedAt.map { "renewedAt: \($0), " } ?? "")
            + (expiresAt.map { "expiresAt: \($0), " } ?? "")
            + (startsAt.map { "startsAt: \($0), " } ?? "")
            + "isLifetime: \(isLifetime), "
            + (activeIntroductoryOfferType.map { "activeIntroductoryOfferType: \($0), " } ?? "")
            + (activePromotionalOfferType.map { "activePromotionalOfferType: \($0), " } ?? "")
            + (activePromotionalOfferId.map { "activePromotionalOfferId: \($0), " } ?? "")
            + (offerId.map { "offerId: \($0), " } ?? "")
            + "willRenew: \(willRenew), isInGracePeriod: \(isInGracePeriod), "
            + (unsubscribedAt.map { "unsubscribedAt: \($0), " } ?? "")
            + (billingIssueDetectedAt.map { "billingIssueDetectedAt: \($0), " } ?? "")
            + (cancellationReason.map { "cancellationReason: \($0), " } ?? "")
            + "isRefund: \(isRefund))"
    }
}

extension AdaptyProfile.AccessLevel: Codable {
    enum CodingKeys: String, CodingKey {
        case id
        case isActive = "is_active"
        case vendorProductId = "vendor_product_id"
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
    }
}
