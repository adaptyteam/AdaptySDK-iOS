//
//  StoreKit.Product.SubscriptionInfo.PricingTerms.swift
//  AdaptySDK
//

import StoreKit

#if compiler(>=6.3.2)

@available(iOS 26.4, macOS 26.4, tvOS 26.4, watchOS 26.4, visionOS 26.4, *)
extension StoreKit.Product.SubscriptionInfo.PricingTerms {
    func asAdaptySubscriptionPricingTerms(
        priceFormatStyle: Decimal.FormatStyle.Currency,
        periodFormatStyle: Date.ComponentsFormatStyle
    ) -> AdaptySubscriptionPricingTerms {
        .init(
            billingPlan: billingPlanType.asAdaptySubscriptionBillingPlan,
            billingPrice: billingPrice,
            localizedBillingPrice: billingDisplayPrice,
            billingPeriod: billingPeriod.asAdaptySubscriptionPeriod,
            priceFormatStyle: priceFormatStyle,
            periodFormatStyle: periodFormatStyle,
            commitmentInfo: commitmentInfo.asAdaptySubscriptionCommitmentInfo(
                priceFormatStyle: priceFormatStyle,
                periodFormatStyle: periodFormatStyle
            )
        )
    }
}
#endif
