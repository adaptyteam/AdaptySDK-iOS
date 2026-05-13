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

extension AdaptyPaywallProduct: ProductResolver {
    public var flowId: String { flowProductId ?? adaptyProductId } // TODO: x check?
    
    public var paymentMode: PaymentModeValue {
        subscriptionOffer?.paymentMode.encodedValue
    }

    private func isApplicableForTag(_ tag: TextProductTag) -> Bool {
        switch tag {
        case .title, .description, .price, .priceAmount, .priceAmountInteger,
             .currencyCode, .currencySymbol:
            true
        case .priceAmountFraction:
            maximumFractionDigits(for: priceLocale) > 0
        case .pricePerDay, .pricePerWeek, .pricePerMonth, .pricePerYear,
             .subscriptionPeriod:
            subscriptionPeriod != nil
        case .offerPrice, .offerPeriods, .offerNumberOfPeriods:
            subscriptionOffer != nil
        }
    }

    public func value(byTag tag: TextProductTag) -> TextTagValue? {
        guard isApplicableForTag(tag) else { return .notApplicable }

        let result: String? =
            switch tag {
            case .title:
                localizedTitle
            case .description:
                localizedDescription
            case .price:
                localizedPrice
            case .priceAmount:
                priceAmount(for: priceLocale)
            case .priceAmountInteger:
                priceAmountInteger(for: priceLocale)
            case .priceAmountFraction:
                priceAmountFraction(for: priceLocale)
            case .currencyCode:
                currencyCode
            case .currencySymbol:
                currencySymbol
            case .pricePerDay:
                pricePer(period: .day)
            case .pricePerWeek:
                pricePer(period: .week)
            case .pricePerMonth:
                pricePer(period: .month)
            case .pricePerYear:
                pricePer(period: .year)
            case .subscriptionPeriod:
                localizedSubscriptionPeriod
            case .offerPrice:
                subscriptionOffer?.localizedPrice
            case .offerPeriods:
                subscriptionOffer?.localizedSubscriptionPeriod
            case .offerNumberOfPeriods:
                subscriptionOffer?.localizedNumberOfPeriods
            }

        if let result {
            return .value(result)
        } else {
            return nil
        }
    }
}

extension AdaptyProduct {
    func pricePer(period: AdaptySubscriptionPeriod.Unit) -> String? {
        guard let subscriptionPeriod else { return nil }

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

    func priceAmount(for locale: Locale) -> String? {
        let digits = maximumFractionDigits(for: locale)
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = locale
        formatter.minimumFractionDigits = digits
        formatter.maximumFractionDigits = digits
        return formatter.string(from: NSDecimalNumber(decimal: price))
    }

    func priceAmountInteger(for locale: Locale) -> String? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = locale
        formatter.maximumFractionDigits = 0
        formatter.roundingMode = .down
        return formatter.string(from: NSDecimalNumber(decimal: price))
    }

    func priceAmountFraction(for locale: Locale) -> String? {
        let fractionDigits = maximumFractionDigits(for: locale)
        guard fractionDigits > 0 else { return nil }

        let multiplier = pow(Decimal(10), fractionDigits)
        var rounded = Decimal()
        var unrounded = price * multiplier
        NSDecimalRound(&rounded, &unrounded, 0, .plain)

        let scaledInteger = NSDecimalNumber(decimal: rounded).int64Value
        let modulus = NSDecimalNumber(decimal: multiplier).int64Value
        let fraction = abs(scaledInteger) % modulus

        return String(format: "%0\(fractionDigits)lld", fraction)
    }

    func maximumFractionDigits(for locale: Locale) -> Int {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = locale
        return formatter.maximumFractionDigits
    }
}

#endif

