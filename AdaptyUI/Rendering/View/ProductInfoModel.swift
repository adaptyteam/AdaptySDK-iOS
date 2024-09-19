//
//  ProductInfoModel.swift
//
//
//  Created by Alexey Goncharov on 27.7.23..
//

#if canImport(UIKit)

import Adapty
import UIKit

@available(iOS 15.0, *)
protocol ProductInfoModel {
    var isPlaceholder: Bool { get }
    var adaptyProductId: String { get }
    var adaptyProduct: AdaptyPaywallProduct? { get }

    var paymentMode: AdaptyProductDiscount.PaymentMode { get }

    func stringByTag(_ tag: AdaptyUI.ProductTag) -> AdaptyUI.ProductTagReplacement?
}

@available(iOS 15.0, *)
extension AdaptyPaywallProduct {
    func isApplicableForTag(_ tag: AdaptyUI.ProductTag) -> Bool {
        switch tag {
        case .title, .price:
            return true
        case .pricePerDay, .pricePerWeek, .pricePerMonth, .pricePerYear,
             .offerPrice, .offerPeriods, .offerNumberOfPeriods:
            return subscriptionPeriod != nil
        }
    }
}

@available(iOS 15.0, *)
struct RealProductInfo: ProductInfoModel {
    var isPlaceholder: Bool { false }
    
    let underlying: AdaptyPaywallProduct
    let introEligibility: AdaptyEligibility

    init(underlying: AdaptyPaywallProduct, introEligibility: AdaptyEligibility) {
        self.underlying = underlying
        self.introEligibility = introEligibility
    }

    var adaptyProductId: String { underlying.adaptyProductId }
    var adaptyProduct: AdaptyPaywallProduct? { underlying }
    var paymentMode: AdaptyProductDiscount.PaymentMode {
        guard let offer = underlying.eligibleDiscount(introEligibility: introEligibility) else { return .unknown}
        return offer.paymentMode
    }

    func stringByTag(_ tag: AdaptyUI.ProductTag) -> AdaptyUI.ProductTagReplacement? {
        guard underlying.isApplicableForTag(tag) else { return .notApplicable }

        let result: String?

        switch tag {
        case .title:
            result = underlying.localizedTitle
        case .price:
            result = underlying.localizedPrice
        case .pricePerDay:
            result = underlying.pricePer(period: .day)
        case .pricePerWeek:
            result = underlying.pricePer(period: .week)
        case .pricePerMonth:
            result = underlying.pricePer(period: .month)
        case .pricePerYear:
            result = underlying.pricePer(period: .year)
        case .offerPrice:
            result = underlying.eligibleDiscount(introEligibility: introEligibility)?.localizedPrice
        case .offerPeriods:
            result = underlying.eligibleDiscount(introEligibility: introEligibility)?.localizedSubscriptionPeriod
        case .offerNumberOfPeriods:
            result = underlying.eligibleDiscount(introEligibility: introEligibility)?.localizedNumberOfPeriods
        }

        if let result = result {
            return .value(result)
        } else {
            return nil
        }
    }
}

#endif
