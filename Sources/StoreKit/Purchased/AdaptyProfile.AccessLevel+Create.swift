//
//  AdaptyProfile.AccessLevel+Create.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 01.08.2025.
//

import StoreKit

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
extension AdaptyProfile.AccessLevel {
    init?(
        sk2Transaction: SK2Transaction,
        sk2Product: SK2Product?,
        backendPeriod: BackendProductInfo.Period?,
        now: Date = Date()
    ) async {
        let productType = sk2Transaction.productType
        let activatedAt = sk2Transaction.originalPurchaseDate
        let isLifetime = backendPeriod == .lifetime
        var isRefund = sk2Transaction.revocationDate != nil

        let offer = PurchasedSubscriptionOfferInfo(
            sk2Transaction: sk2Transaction,
            sk2Product: sk2Product
        )
        let expiresAt: Date?

        var subscriprionNotEntitled = false
        var subscriptionWillRenew = false
        var subscriptionRenewedAt: Date?
        var subscriptionInGracePeriod = false
        var subscriptionUnsubscribedAt: Date?
        var subscriptionExpirationReason: Product.SubscriptionInfo.RenewalInfo.ExpirationReason?
        var subscriptionGracePeriodExpiredAt: Date?

        switch productType {
        case .autoRenewable:
            if let subscriptionStatus = await sk2Transaction.subscriptionStatus {
                let state = subscriptionStatus.state

                if let renewalInfo = try? subscriptionStatus.renewalInfo.payloadValue {
                    subscriptionWillRenew = renewalInfo.willAutoRenew
                    subscriptionExpirationReason = renewalInfo.expirationReason
                    subscriptionGracePeriodExpiredAt = renewalInfo.gracePeriodExpirationDate

                    if renewalInfo.expirationReason == .billingError {
                        if renewalInfo.isInBillingRetry {
                            subscriprionNotEntitled = renewalInfo.gracePeriodExpirationDate == nil
                        } else {
                            subscriprionNotEntitled = true
                        }
                    }
                }
                subscriptionInGracePeriod = state == .inGracePeriod
                isRefund = state == .revoked || isRefund
            }

            subscriptionRenewedAt = sk2Transaction.purchaseDate == activatedAt ? nil : sk2Transaction.purchaseDate

            expiresAt = sk2Transaction.revocationDate
                ?? subscriptionGracePeriodExpiredAt
                ?? sk2Transaction.expirationDate

            if !subscriptionWillRenew, let expiresAt {
                subscriptionUnsubscribedAt = min(now, expiresAt)
            }

        default:
            expiresAt = sk2Transaction.revocationDate
                ?? sk2Transaction.expirationDate
                ?? backendPeriod?.expiresAt(startedAt: sk2Transaction.purchaseDate)
        }

        guard expiresAt != nil || isLifetime else { return nil }

        self.init(
            id: UUID().uuidString,
            isActive: {
                if subscriprionNotEntitled { return false }
                if isRefund { return false }
                if isLifetime { return true }
                if let expiresAt, now > expiresAt { return false }
                return true
            }(),
            vendorProductId: sk2Transaction.unfProductID,
            store: "app_store",
            activatedAt: activatedAt,
            renewedAt: subscriptionRenewedAt,
            expiresAt: expiresAt,
            isLifetime: isLifetime,
            activeIntroductoryOfferType: offer?.activeIntroductoryOfferType,
            activePromotionalOfferType: offer?.activePromotionalOfferType,
            activePromotionalOfferId: offer?.activePromotionalOfferId,
            offerId: nil, // Android Only
            willRenew: subscriptionWillRenew,
            isInGracePeriod: subscriptionInGracePeriod,
            unsubscribedAt: subscriptionUnsubscribedAt,
            billingIssueDetectedAt: nil, // TODO: need calculate
            startsAt: nil, // Backend Only
            cancellationReason: subscriptionExpirationReason?.asString(isRefund),
            isRefund: isRefund
        )
    }
}

private extension PurchasedSubscriptionOfferInfo {
    var activeIntroductoryOfferType: String? {
        (offerType == .introductory) ? paymentMode.encodedValue : nil
    }

    var activePromotionalOfferType: String? {
        (offerType == .promotional) ? paymentMode.encodedValue : nil
    }

    var activePromotionalOfferId: String? {
        (offerType == .promotional) ? id : nil
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
private extension Product.SubscriptionInfo.RenewalInfo.ExpirationReason {
    func asString(_ isRefund: Bool) -> String {
        guard !isRefund else {
            return "refund"
        }
        return switch self {
        case .autoRenewDisabled:
            "voluntarily_cancelled"
        case .billingError:
            "billing_error"
        case .didNotConsentToPriceIncrease:
            "price_increase"
        case .productUnavailable:
            "product_was_not_available"
        default:
            "unknown"
        }
    }
}
