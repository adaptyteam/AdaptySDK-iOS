//
//  AdaptySubscriptionPricingTerms.swift
//  AdaptySDK
//

import Foundation
import StoreKit

public struct AdaptySubscriptionPricingTerms: Sendable, Hashable {
    public let billingPlan: AdaptySubscriptionBillingPlan
    public let billingPrice: Decimal
    public let localizedBillingPrice: String
    public let billingPeriod: AdaptySubscriptionPeriod
    public let commitmentInfo: AdaptySubscriptionCommitmentInfo

    package init(
        billingPlan: AdaptySubscriptionBillingPlan,
        billingPrice: Decimal,
        localizedBillingPrice: String,
        billingPeriod: AdaptySubscriptionPeriod,
        priceFormatStyle: Decimal.FormatStyle.Currency,
        periodFormatStyle: Date.ComponentsFormatStyle,
        commitmentInfo: AdaptySubscriptionCommitmentInfo
    ) {
        self.billingPlan = billingPlan
        self.billingPrice = billingPrice
        self.localizedBillingPrice = localizedBillingPrice
        self.billingPeriod = billingPeriod
        self.commitmentInfo = commitmentInfo
    }
}

extension AdaptySubscriptionPricingTerms {
    static func upFront(
        price: Decimal,
        localizedPrice: String,
        subscriptionPeriod:  AdaptySubscriptionPeriod,
        priceFormatStyle: Decimal.FormatStyle.Currency,
        periodFormatStyle: Date.ComponentsFormatStyle
    ) -> Self?{
        .init(
            billingPlan: .upFront,
            billingPrice: price,
            localizedBillingPrice: localizedPrice,
            billingPeriod: subscriptionPeriod,
            priceFormatStyle: priceFormatStyle,
            periodFormatStyle: periodFormatStyle,
            commitmentInfo: .init(
                price: price,
                localizedPrice: localizedPrice,
                period: subscriptionPeriod,
                priceFormatStyle: priceFormatStyle,
                periodFormatStyle: periodFormatStyle
            )
        )
    }
}
