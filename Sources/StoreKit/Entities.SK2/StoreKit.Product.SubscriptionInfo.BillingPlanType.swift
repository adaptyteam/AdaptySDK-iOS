//
//  StoreKit.Product.SubscriptionInfo.BillingPlanType.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 18.09.2026.
//

import StoreKit

#if compiler(>=6.3.2)

@available(iOS 26.4, macOS 26.4, tvOS 26.4, watchOS 26.4, visionOS 26.4, *)
extension StoreKit.Product.SubscriptionInfo.BillingPlanType {
    @inlinable
    var asAdaptySubscriptionBillingPlan: AdaptySubscriptionBillingPlan {
        switch self {
        case .upFront: .upFront
        case .monthly: .monthly
        default: .init(rawValue: rawValue)
        }
    }
}

@available(iOS 26.4, macOS 26.4, tvOS 26.4, watchOS 26.4, visionOS 26.4, *)
extension AdaptySubscriptionBillingPlan {
    @inlinable
    var asSKBillingPlanType: StoreKit.Product.SubscriptionInfo.BillingPlanType {
        switch self {
        case .upFront: .upFront
        case .monthly: .monthly
        default: .init(rawValue: rawValue)
        }
    }
}
#endif
