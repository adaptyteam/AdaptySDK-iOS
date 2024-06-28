//
//  AdaptyPaywallProductExtensions.swift
//
//
//  Created by Alexey Goncharov on 2023-01-24.
//

import Adapty
import Foundation

extension NSDecimalNumber {
    var isInteger: Bool {
        return self == rounding(accordingToBehavior: nil)
    }
}

extension Locale {
    func defaultPriceNumberFormatter(_ price: NSDecimalNumber) -> NumberFormatter {
        let formatter = NumberFormatter()

        formatter.numberStyle = .currency
        formatter.locale = self
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        formatter.roundingMode = .ceiling

        return formatter
    }

    func eurAndUsdPriceNumberFormatter(_ price: NSDecimalNumber) -> NumberFormatter {
        let formatter = NumberFormatter()

        formatter.numberStyle = .currency
        formatter.locale = self
        formatter.minimumFractionDigits = price.isInteger ? 0 : 2
        formatter.maximumFractionDigits = price.isInteger ? 0 : 2
        formatter.roundingMode = .ceiling

        return formatter
    }

    func priceNumberFormatter(_ price: NSDecimalNumber) -> NumberFormatter {
        switch currencySymbol {
        case "EUR", "USD": eurAndUsdPriceNumberFormatter(price)
        default: defaultPriceNumberFormatter(price)
        }
    }
}

extension AdaptyPaywallProduct {
    func eligibleDiscount(introEligibility: AdaptyEligibility) -> AdaptyProductDiscount? {
        if promotionalOfferEligibility, let promotionalOfferId = promotionalOfferId,
           let promotionalOffer = discount(byIdentifier: promotionalOfferId)
        {
            return promotionalOffer
        } else if introEligibility == .eligible {
            return introductoryDiscount
        } else {
            return nil
        }
    }

    func pricePer(period: AdaptyPeriodUnit) -> String? {
        guard let subscriptionPeriod = subscriptionPeriod else { return nil }

        let numberOfPeriods = subscriptionPeriod.numberOfPeriods(period)
        guard numberOfPeriods > 0.0 else { return nil }

        let numberOfPeriodsDecimal = Decimal(floatLiteral: numberOfPeriods)
        let pricePerPeriod = price / numberOfPeriodsDecimal
        let nsDecimalPricePerPeriod = NSDecimalNumber(decimal: pricePerPeriod)

        let formatter = skProduct.priceLocale.priceNumberFormatter(nsDecimalPricePerPeriod)
        return formatter.string(from: nsDecimalPricePerPeriod)
    }
}
