//
//  AdaptyProfile.AccessLevel+Create.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 01.08.2025.
//

import StoreKit

extension AdaptyProfile.AccessLevel {
    init?(
        id: String,
        transaction: StoreKit.Transaction,
        product: StoreKit.Product?,
        backendPeriod: BackendProductInfo.Period?,
        now: Date = Date()
    ) async {
        let productType = transaction.productType
        let activatedAt = transaction.originalPurchaseDate
        let isLifetime = backendPeriod == .lifetime
        var isRefund = transaction.revocationDate != nil

        let offer = SubscriptionOfferInfo(
            transaction: transaction,
            product: product
        )
        let expiresAt: Date?

        var subscriprionNotEntitled = false
        var subscriptionWillRenew = false
        var subscriptionRenewedAt: Date?
        var subscriptionInGracePeriod = false
        var subscriptionUnsubscribedAt: Date?
        var subscriptionExpirationReason: Product.SubscriptionInfo.RenewalInfo.ExpirationReason?
        var subscriptionGracePeriodExpiredAt: Date?

        var renewalInfoSignedAt: Date?

        switch productType {
        case .autoRenewable:
            if let subscriptionStatus = await transaction.subscriptionStatus {
                let state = subscriptionStatus.state

                if let renewalInfo = try? subscriptionStatus.renewalInfo.payloadValue {
                    renewalInfoSignedAt = subscriptionStatus.renewalInfo.signedDate
                    subscriptionWillRenew = renewalInfo.subscriptionWillRenew
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

            subscriptionRenewedAt = transaction.purchaseDate == activatedAt ? nil : transaction.purchaseDate

            expiresAt = transaction.revocationDate
                ?? subscriptionGracePeriodExpiredAt
                ?? transaction.expirationDate

            if !subscriptionWillRenew, let expiresAt {
                subscriptionUnsubscribedAt = min(now, expiresAt)
            }

        default:
            expiresAt = transaction.revocationDate
                ?? transaction.expirationDate
                ?? backendPeriod?.expiresAt(startedAt: transaction.purchaseDate)
        }

        guard expiresAt != nil || isLifetime else { return nil }

        self.init(
            id: id,
            isActive: {
                if subscriprionNotEntitled { return false }
                if isRefund { return false }
                if isLifetime { return true }
                if let expiresAt, now > expiresAt { return false }
                return true
            }(),
            vendorProductId: transaction.productID,
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
            billingPlan: transaction.unfBillingPlan,
            commitmentInfo: transaction.subscriptionCommitmentInfo,
            cancellationReason: subscriptionExpirationReason?.asString(isRefund),
            isRefund: isRefund,
            renewalInfoSignedAt: renewalInfoSignedAt ?? Date(timeIntervalSince1970: 0)
        )
    }
}

private extension Product.SubscriptionInfo.RenewalInfo {
    var subscriptionWillRenew:  Bool {
        #if compiler(>=6.3.2)
        if #available(iOS 26.4, macOS 26.4, tvOS 26.4, watchOS 26.4, visionOS 26.4, *) {
            // Report renewal of the commitment when one is present.
            return commitmentInfo?.willAutoRenew ?? willAutoRenew
        }
        #endif
        return willAutoRenew
    }
}

private extension Transaction {
    var subscriptionCommitmentInfo: AdaptyProfile.SubscriptionCommitmentInfo? {
        #if compiler(>=6.3.2)
        guard #available(iOS 26.4, macOS 26.4, tvOS 26.4, watchOS 26.4, visionOS 26.4, *), let commitmentInfo  else { return nil }

        return .init(
            billingPeriodNumber: UInt(commitmentInfo.billingPeriodNumber),
            totalBillingPeriods: UInt(commitmentInfo.totalBillingPeriods),
            expiresAt: commitmentInfo.expirationDate
        )
        #else
        return nil
        #endif
    }
}

private struct SubscriptionOfferInfo {
    let id: String?
    let offerType: AdaptyTransactionOfferType
    let paymentMode: AdaptySubscriptionOffer.PaymentMode

    init?(
        transaction: StoreKit.Transaction,
        product: StoreKit.Product?
    ) {

        guard #available(iOS 17.2, macOS 14.2, tvOS 17.2, watchOS 10.2, visionOS 1.1, *) else {
            guard let offerType = transaction.offerType?.asAdaptyTransactionOfferType else { return nil }
            let offerId = transaction.offerID

            self.id = offerId
            self.offerType = offerType

            self.paymentMode =
                if let product, let offerType = offerType.asAdaptySubscriptionOfferType {
                    product.subscription?
                        .offer(
                            by: .init(offerId: offerId, offerType: offerType),
                            for: .upFront
                        )?
                        .paymentMode
                        .asAdaptySubscriptionOfferPaymentMode ?? .unknown
                } else {
                    .unknown
                }
            return
        }

        guard let offer = transaction.offer else { return nil }

        self.id = offer.id
        self.offerType = offer.type.asAdaptyTransactionOfferType
        self.paymentMode = offer.paymentMode?.asAdaptySubscriptionOfferPaymentMode ?? .unknown

    }

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
