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
    var eligibleOffer: AdaptyProductDiscount? { get } // TODO: refactor
    var isEligibleForFreeTrial: Bool { get } // TODO: remove

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
    
    let product: AdaptyPaywallProduct
    let introEligibility: AdaptyEligibility

    var eligibleOffer: AdaptyProductDiscount? { product.eligibleDiscount(introEligibility: introEligibility) }

    var isEligibleForFreeTrial: Bool {
        guard let offer = eligibleOffer else { return false }
        return offer.paymentMode == .freeTrial
    }

    init(product: AdaptyPaywallProduct, introEligibility: AdaptyEligibility) {
        self.product = product
        self.introEligibility = introEligibility
    }

    var adaptyProductId: String { product.adaptyProductId }
    var adaptyProduct: AdaptyPaywallProduct? { product }
    var paymentMode: AdaptyProductDiscount.PaymentMode { eligibleOffer?.paymentMode ?? .unknown }

    func stringByTag(_ tag: AdaptyUI.ProductTag) -> AdaptyUI.ProductTagReplacement? {
        guard product.isApplicableForTag(tag) else { return .notApplicable }

        let result: String?

        switch tag {
        case .title:
            result = product.localizedTitle
        case .price:
            result = product.localizedPrice
        case .pricePerDay:
            result = product.pricePer(period: .day)
        case .pricePerWeek:
            result = product.pricePer(period: .week)
        case .pricePerMonth:
            result = product.pricePer(period: .month)
        case .pricePerYear:
            result = product.pricePer(period: .year)
        case .offerPrice:
            result = product.eligibleDiscount(introEligibility: introEligibility)?.localizedPrice
        case .offerPeriods:
            result = product.eligibleDiscount(introEligibility: introEligibility)?.localizedSubscriptionPeriod
        case .offerNumberOfPeriods:
            result = product.eligibleDiscount(introEligibility: introEligibility)?.localizedNumberOfPeriods
        }

        if let result = result {
            return .value(result)
        } else {
            return nil
        }
    }
}

#endif
