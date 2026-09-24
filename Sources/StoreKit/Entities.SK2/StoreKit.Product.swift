//
//  StoreKit.Product.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 01.02.2024
//

import StoreKit

extension StoreKit.Product {
    func subscriptionPricingTerms(for billingPlan: AdaptySubscriptionBillingPlan) -> AdaptySubscriptionPricingTerms? {
        guard let subscription else { return nil }

        #if compiler(>=6.3.2)
        if #available(iOS 26.4, macOS 26.4, tvOS 26.4, watchOS 26.4, visionOS 26.4, *),
           let skPricingTerms = subscription.pricingTerms(for: billingPlan.asSKBillingPlanType)
        {
            return skPricingTerms.asAdaptySubscriptionPricingTerms
        }
        #endif

        guard billingPlan == .upFront else { return nil }

        return AdaptySubscriptionPricingTerms.upFront(
            price: price,
            localizedPrice: displayPrice,
            subscriptionPeriod: subscription.subscriptionPeriod.asAdaptySubscriptionPeriod
        )
    }
}
