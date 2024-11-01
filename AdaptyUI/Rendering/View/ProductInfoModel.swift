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

    var paymentMode: AdaptySubscriptionOffer.PaymentMode { get }

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

extension AdaptySubscriptionOffer.Available {
    var availableOffer: AdaptySubscriptionOffer? {
        switch self {
        case .available(let offer):
            return offer
        default:
            return nil
        }
    }
}

@available(iOS 15.0, *)
struct RealProductInfo: ProductInfoModel {
    var isPlaceholder: Bool { false }
    
    let underlying: AdaptyPaywallProduct

    init(underlying: AdaptyPaywallProduct) {
        self.underlying = underlying
    }

    var adaptyProductId: String { underlying.adaptyProductId }
    var adaptyProduct: AdaptyPaywallProduct? { underlying }
    var paymentMode: AdaptySubscriptionOffer.PaymentMode {
        underlying.subscriptionOffer.availableOffer?.paymentMode ?? .unknown
    }

    func stringByTag(_ tag: AdaptyUI.ProductTag) -> AdaptyUI.ProductTagReplacement? {
        guard underlying.isApplicableForTag(tag) else { return .notApplicable }

        let result: String? = switch tag {
        case .title:
            underlying.localizedTitle
        case .price:
            underlying.localizedPrice
        case .pricePerDay:
            underlying.pricePer(period: .day)
        case .pricePerWeek:
            underlying.pricePer(period: .week)
        case .pricePerMonth:
            underlying.pricePer(period: .month)
        case .pricePerYear:
            underlying.pricePer(period: .year)
        case .offerPrice:
            underlying.subscriptionOffer.availableOffer?.localizedPrice
        case .offerPeriods:
            underlying.subscriptionOffer.availableOffer?.localizedSubscriptionPeriod
        case .offerNumberOfPeriods:
            underlying.subscriptionOffer.availableOffer?.localizedNumberOfPeriods
        }

        if let result = result {
            return .value(result)
        } else {
            return nil
        }
    }
}

#endif
