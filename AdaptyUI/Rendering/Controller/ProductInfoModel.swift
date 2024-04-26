//
//  ProductInfoModel.swift
//
//
//  Created by Alexey Goncharov on 27.7.23..
//

import Adapty
import UIKit

protocol ProductInfoModel {
    var id: String { get }
    var adaptyProduct: AdaptyPaywallProduct? { get }
    var eligibleOffer: AdaptyProductDiscount? { get }
    var tagConverter: AdaptyUI.ProductTagConverter { get }
    var isEligibleForFreeTrial: Bool { get }
}

struct EmptyProductInfo: ProductInfoModel {
    let id: String
    var adaptyProduct: AdaptyPaywallProduct? { nil }
    var eligibleOffer: AdaptyProductDiscount? { nil }
    var tagConverter: AdaptyUI.ProductTagConverter { { _ in nil } }
    var isEligibleForFreeTrial: Bool { false }

    init(id: String) {
        self.id = id
    }
}

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

struct RealProductInfo: ProductInfoModel {
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

    var id: String { product.vendorProductId }
    var adaptyProduct: AdaptyPaywallProduct? { product }

    var tagConverter: AdaptyUI.ProductTagConverter {
        { tag in
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
}

extension ProductInfoModel {
    static func empty(id: String) -> ProductInfoModel {
        EmptyProductInfo(id: id)
    }

    static func real(product: AdaptyPaywallProduct, introEligibility: AdaptyEligibility) -> ProductInfoModel {
        RealProductInfo(product: product, introEligibility: introEligibility)
    }
}
