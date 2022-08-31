//
//  CustomStringConvertible.swift
//  Adapty
//
//  Created by Ilya Laryionau on 10/5/20.
//  Copyright © 2020 Adapty. All rights reserved.
//

// MARK: - PaywallModel

extension PaywallModel {
    override public var description: String {
        let keysAndValues: [String: Any?] = [
            "id": id,
            "variationId": variationId,
            "revision": revision,
            "products": products,
            "customPayloadString": customPayloadString,
            "customPayload": customPayload,
            "abTestName": abTestName,
            "name": name,
        ]

        return keysAndValues
            .compactMapValues { $0 }
            .map { "\($0.key): \($0.value)" }
            .joined(separator: ", ")
    }
}

// MARK: - ProductModel

extension ProductModel {
    override public var description: String {
        let keysAndValues: [String: Any?] = [
            "vendorProductId": vendorProductId,
            "introductoryOfferEligibility": introductoryOfferEligibility,
            "promotionalOfferEligibility": promotionalOfferEligibility,
            "promotionalOfferId": promotionalOfferId,
            "variationId": variationId,
            "paywallABTestName": paywallABTestName,
            "paywallName": paywallName,
            "localizedDescription": localizedDescription,
            "localizedTitle": localizedTitle,
            "price": price,
            "currencyCode": currencyCode,
            "currencySymbol": currencySymbol,
            "regionCode": regionCode,
            "isFamilyShareable": isFamilyShareable,
            "subscriptionPeriod": subscriptionPeriod,
            "introductoryDiscount": introductoryDiscount,
            "subscriptionGroupIdentifier": subscriptionGroupIdentifier,
            "discounts": discounts,
            "localizedPrice": localizedPrice,
            "localizedSubscriptionPeriod": localizedSubscriptionPeriod,
        ]

        return keysAndValues
            .compactMapValues { $0 }
            .map { "\($0.key): \($0.value)" }
            .joined(separator: ", ")
    }
}

extension ProductModel.PeriodUnit: CustomStringConvertible {
    public var description: String {
        switch self {
        case .day:
            return "day"
        case .week:
            return "week"
        case .month:
            return "month"
        case .year:
            return "year"
        case .unknown:
            return "unknown"
        }
    }
}

extension ProductSubscriptionPeriodModel {
    override public var description: String {
        let keysAndValues: [String: Any?] = [
            "unit": unit,
            "numberOfUnits": numberOfUnits,
        ]

        return keysAndValues
            .compactMapValues { $0 }
            .map { "\($0.key): \($0.value)" }
            .joined(separator: ", ")
    }
}

extension ProductDiscountModel {
    override public var description: String {
        let keysAndValues: [String: Any?] = [
            "price": price,
            "identifier": identifier,
            "subscriptionPeriod": subscriptionPeriod,
            "numberOfPeriods": numberOfPeriods,
            "paymentMode": paymentMode,
            "localizedPrice": localizedPrice,
            "localizedSubscriptionPeriod": localizedSubscriptionPeriod,
            "localizedNumberOfPeriods": localizedNumberOfPeriods,
        ]

        return keysAndValues
            .compactMapValues { $0 }
            .map { "\($0.key): \($0.value)" }
            .joined(separator: ", ")
    }
}

extension ProductDiscountModel.PaymentMode: CustomStringConvertible {
    public var description: String {
        switch self {
        case .payAsYouGo:
            return "payAsYouGo"
        case .payUpFront:
            return "payUpFront"
        case .freeTrial:
            return "freeTrial"
        case .unknown:
            return "unknown"
        }
    }
}

// MARK: - PurchaserInfoModel

extension PurchaserInfoModel {
    override public var description: String {
        let keysAndValues: [String: Any?] = [
            "accessLevels": accessLevels,
            "subscriptions": subscriptions,
            "nonSubscriptions": nonSubscriptions,
        ]

        return keysAndValues
            .compactMapValues { $0 }
            .map { "\($0.key): \($0.value)" }
            .joined(separator: ", ")
    }
}

extension AccessLevelInfoModel {
    override public var description: String {
        let keysAndValues: [String: Any?] = [
            "id": id,
            "isActive": isActive,
            "vendorProductId": vendorProductId,
            "store": store,
            "activatedAt": activatedAt,
            "renewedAt": renewedAt,
            "expiresAt": expiresAt,
            "isLifetime": isLifetime,
            "activeIntroductoryOfferType": activeIntroductoryOfferType,
            "activePromotionalOfferType": activePromotionalOfferType,
            "willRenew": willRenew,
            "isInGracePeriod": isInGracePeriod,
            "unsubscribedAt": unsubscribedAt,
            "billingIssueDetectedAt": billingIssueDetectedAt,
            "vendorTransactionId": vendorTransactionId,
            "vendorOriginalTransactionId": vendorOriginalTransactionId,
            "startsAt": startsAt,
            "cancellationReason": cancellationReason,
            "isRefund": isRefund,
        ]

        return keysAndValues
            .compactMapValues { $0 }
            .map { "\($0.key): \($0.value)" }
            .joined(separator: ", ")
    }
}

extension SubscriptionInfoModel {
    override public var description: String {
        let keysAndValues: [String: Any?] = [
            "isActive": isActive,
            "vendorProductId": vendorProductId,
            "store": store,
            "activatedAt": activatedAt,
            "renewedAt": renewedAt,
            "expiresAt": expiresAt,
            "startsAt": startsAt,
            "isLifetime": isLifetime,
            "activeIntroductoryOfferType": activeIntroductoryOfferType,
            "activePromotionalOfferType": activePromotionalOfferType,
            "willRenew": willRenew,
            "isInGracePeriod": isInGracePeriod,
            "unsubscribedAt": unsubscribedAt,
            "billingIssueDetectedAt": billingIssueDetectedAt,
            "isSandbox": isSandbox,
            "vendorTransactionId": vendorTransactionId,
            "vendorOriginalTransactionId": vendorOriginalTransactionId,
            "cancellationReason": cancellationReason,
            "isRefund": isRefund,
        ]

        return keysAndValues
            .compactMapValues { $0 }
            .map { "\($0.key): \($0.value)" }
            .joined(separator: ", ")
    }
}

extension NonSubscriptionInfoModel {
    override public var description: String {
        let keysAndValues: [String: Any?] = [
            "purchaseId": purchaseId,
            "vendorProductId": vendorProductId,
            "store": store,
            "purchasedAt": purchasedAt,
            "isOneTime": isOneTime,
            "isSandbox": isSandbox,
            "vendorTransactionId": vendorTransactionId,
            "vendorOriginalTransactionId": vendorOriginalTransactionId,
            "isRefund": isRefund,
        ]

        return keysAndValues
            .compactMapValues { $0 }
            .map { "\($0.key): \($0.value)" }
            .joined(separator: ", ")
    }
}
