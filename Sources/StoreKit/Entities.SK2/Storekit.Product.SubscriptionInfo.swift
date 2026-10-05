//
//  Storekit.Product.SubscriptionInfo.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 19.09.2026.
//

import StoreKit

extension StoreKit.Product.SubscriptionInfo {
    @inlinable
    func availableBillingPlan(for billingPlan: AdaptySubscriptionBillingPlan) -> Bool {
        if billingPlan == .upFront {
            return true
        }
        #if compiler(>=6.3.2)
        if #available(iOS 26.4, macOS 26.4, tvOS 26.4, watchOS 26.4, visionOS 26.4, *) {
            return availableBillingPlan(for: billingPlan.asSKBillingPlanType)
        }
        #endif
        return false
    }

    func offer(
        by offerIdentifier: AdaptySubscriptionOffer.Identifier,
        for billingPlan: AdaptySubscriptionBillingPlan
    ) -> Product.SubscriptionOffer? {
        #if compiler(>=6.3.2)
        if #available(iOS 26.4, macOS 26.4, tvOS 26.4, watchOS 26.4, visionOS 26.4, *) {
            return  pricingTerms(for: billingPlan.asSKBillingPlanType)?.offer(by: offerIdentifier)
        }
        #endif

        // Legacy offers belong to the up-front plan only.
        guard billingPlan == .upFront else { return nil }

        switch offerIdentifier.offerType {
        case .introductory:
            return introductoryOffer
        case .promotional:
            guard let offerId = offerIdentifier.offerId else { return nil }
            return promotionalOffers.first { $0.id == offerId }
        case .winBack:
            guard #available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *),
                let offerId = offerIdentifier.offerId
            else { return nil }
            return winBackOffers.first { $0.id == offerId }
        default:
            return nil
        }
    }
}

#if compiler(>=6.3.2)
@available(iOS 26.4, macOS 26.4, tvOS 26.4, watchOS 26.4, visionOS 26.4, *)
extension StoreKit.Product.SubscriptionInfo {
    @inlinable
    func availableBillingPlan(for billingPlanType: BillingPlanType) -> Bool {
        pricingTerms.contains {  $0.billingPlanType == billingPlanType  }
    }

    @inlinable
    func pricingTerms(for billingPlanType: BillingPlanType) -> PricingTerms? {
        pricingTerms.first { $0.billingPlanType == billingPlanType }
    }
}

@available(iOS 26.4, macOS 26.4, tvOS 26.4, watchOS 26.4, visionOS 26.4, *)
extension StoreKit.Product.SubscriptionInfo.PricingTerms {
    func offer(
        by offerIdentifier: AdaptySubscriptionOffer.Identifier
    ) -> Product.SubscriptionOffer? {
        let offerType = offerIdentifier.offerType.asSKSubscriptionOfferType
        return if offerType == .introductory {
            subscriptionOffers.first { $0.type == offerType }
        } else {
             subscriptionOffers.first { $0.type == offerType && $0.id == offerIdentifier.offerId }
        }
    }
}
#endif
