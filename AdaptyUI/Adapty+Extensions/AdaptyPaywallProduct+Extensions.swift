//
//  AdaptyPaywallProductExtensions.swift
//
//
//  Created by Alexey Goncharov on 2023-01-24.
//

import Adapty
import Foundation

@available(iOS 15.0, *)
extension AdaptyProduct {
    func pricePer(period: AdaptyPeriodUnit) -> String? {
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
