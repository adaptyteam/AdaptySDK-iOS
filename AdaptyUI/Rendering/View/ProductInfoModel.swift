//
//  ProductInfoModel.swift
//
//
//  Created by Alexey Goncharov on 27.7.23..
//

#if canImport(UIKit)

import Adapty
import UIKit

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
protocol ProductInfoModel {
    var anyProduct: AdaptyPaywallProductWithoutDeterminingOffer { get }
    var adaptyProductId: String { get }
    var adaptyProduct: AdaptyPaywallProduct? { get }

    var paymentMode: AdaptySubscriptionOffer.PaymentMode { get }

    func stringByTag(_ tag: AdaptyUICore.ProductTag) -> AdaptyUICore.ProductTagReplacement?
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
enum AdaptyPaywallProductWrapper {
    case withoutOffer(AdaptyPaywallProductWithoutDeterminingOffer)
    case full(AdaptyPaywallProduct)
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
extension AdaptyPaywallProductWrapper: ProductInfoModel {
    var anyProduct: AdaptyPaywallProductWithoutDeterminingOffer {
        switch self {
        case .withoutOffer(let v): v
        case .full(let v): v
        }
    }

    func isApplicableForTag(_ tag: AdaptyUICore.ProductTag) -> Bool {
        switch tag {
        case .title, .price:
            return true
        case .pricePerDay, .pricePerWeek, .pricePerMonth, .pricePerYear:
            return anyProduct.subscriptionPeriod != nil
        case .offerPrice, .offerPeriods, .offerNumberOfPeriods:
            return adaptyProduct?.subscriptionOffer != nil
        }
    }

    var adaptyProductId: String { anyProduct.adaptyProductId }

    var adaptyProduct: AdaptyPaywallProduct? {
        switch self {
        case .withoutOffer: nil
        case .full(let v): v
        }
    }

    var paymentMode: AdaptySubscriptionOffer.PaymentMode {
        adaptyProduct?.subscriptionOffer?.paymentMode ?? .unknown
    }

    func stringByTag(_ tag: AdaptyUICore.ProductTag) -> AdaptyUICore.ProductTagReplacement? {
        guard isApplicableForTag(tag) else { return .notApplicable }

        let result: String?
        switch tag {
        case .title:
            result = anyProduct.localizedTitle
        case .price:
            result = anyProduct.localizedPrice
        case .pricePerDay:
            result = anyProduct.pricePer(period: .day)
        case .pricePerWeek:
            result = anyProduct.pricePer(period: .week)
        case .pricePerMonth:
            result = anyProduct.pricePer(period: .month)
        case .pricePerYear:
            result = anyProduct.pricePer(period: .year)
        case .offerPrice:
            result = adaptyProduct?.subscriptionOffer?.localizedPrice
        case .offerPeriods:
            result = adaptyProduct?.subscriptionOffer?.localizedSubscriptionPeriod
        case .offerNumberOfPeriods:
            result = adaptyProduct?.subscriptionOffer?.localizedNumberOfPeriods
        }

        if let result = result {
            return .value(result)
        } else {
            return nil
        }
    }
}

#endif
