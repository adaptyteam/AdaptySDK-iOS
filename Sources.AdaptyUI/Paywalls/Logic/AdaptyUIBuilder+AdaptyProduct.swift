//
//  AdaptyUIBuilder+AdaptyProduct.swift
//
//
//  Created by Alexey Goncharov on 2023-01-24.
//

#if canImport(UIKit)

import Adapty
import AdaptyUIBuilder
import Foundation

enum AdaptyPaywallProductWrapper {
    case withoutOffer(AdaptyPaywallProductWithoutDeterminingOffer)
    case full(AdaptyPaywallProduct)
}

extension AdaptyPaywallProductWrapper: ProductResolver {
    private var anyProduct: AdaptyPaywallProductWithoutDeterminingOffer {
        switch self {
        case .withoutOffer(let v): v
        case .full(let v): v
        }
    }

    var paymentMode: String? {
        adaptyProduct?.subscriptionOffer?.paymentMode.encodedValue
    }

    var adaptyProductId: String { anyProduct.adaptyProductId }

    private var adaptyProduct: AdaptyPaywallProduct? {
        switch self {
        case .withoutOffer: nil
        case .full(let v): v
        }
    }

    private func isApplicableForTag(_ tag: TextProductTag) -> Bool {
        switch tag {
        case .title, .price:
            return true
        case .pricePerDay, .pricePerWeek, .pricePerMonth, .pricePerYear:
            return anyProduct.subscriptionPeriod != nil
        case .offerPrice, .offerPeriods, .offerNumberOfPeriods:
            return adaptyProduct?.subscriptionOffer != nil
        }
    }

    func value(byTag tag: TextProductTag) -> TextTagValue? {
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

extension AdaptyProduct {
    func pricePer(period: AdaptySubscriptionPeriod.Unit) -> String? {
        guard let skProduct = sk2Product else { return nil }
        guard let subscriptionPeriod = subscriptionPeriod else { return nil }

        let numberOfPeriods = subscriptionPeriod.numberOfPeriods(period)
        guard numberOfPeriods > 0.0 else { return nil }

        let numberOfPeriodsDecimal = Decimal(floatLiteral: numberOfPeriods)
        let pricePerPeriod = price / numberOfPeriodsDecimal
        let nsDecimalPricePerPeriod = NSDecimalNumber(decimal: pricePerPeriod)

        let formatter = NumberFormatter()

        formatter.numberStyle = .currency
        formatter.locale = skProduct.priceFormatStyle.locale

        return formatter.string(from: nsDecimalPricePerPeriod)
    }
}

#endif
