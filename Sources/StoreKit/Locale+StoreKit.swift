//
//  Locale+StoreKit.swift
//  Adapty
//
//  Created by Andrey Kyashkin on 28/10/2019.
//  Copyright © 2019 Adapty. All rights reserved.
//

import StoreKit

extension Locale {
    func localized(price: NSNumber) -> String? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = self
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        return formatter.string(from: price)
    }

    @available(iOS 11.2, macOS 10.13.2, *)
    func localized(period: SKProductSubscriptionPeriod) -> String? {
        switch period.unit {
        case .day:
            if period.numberOfUnits == 7 { return localizedComponents(weekOfMonth: 1) }
            return localizedComponents(day: period.numberOfUnits)
        case .week:
            return localizedComponents(weekOfMonth: period.numberOfUnits)
        case .month:
            return localizedComponents(month: period.numberOfUnits)
        case .year:
            return localizedComponents(year: period.numberOfUnits)
        @unknown default:
            return nil
        }
    }

    @available(iOS 11.2, macOS 10.13.2, *)
    func localized(numberOfPeriods discount: SKProductDiscount) -> String? {
        let resultingNumber = discount.numberOfPeriods * discount.subscriptionPeriod.numberOfUnits
        
        switch discount.subscriptionPeriod.unit {
        case .day:
            return localizedComponents(day: resultingNumber)
        case .week:
            return localizedComponents(weekOfMonth: resultingNumber)
        case .month:
            return localizedComponents(month: resultingNumber)
        case .year:
            return localizedComponents(year: resultingNumber)
        @unknown default:
            return nil
        }
    }

    private func localizedComponents(day: Int? = nil, weekOfMonth: Int? = nil, month: Int? = nil, year: Int? = nil) -> String? {
        var calendar = Calendar.current
        calendar.locale = self

        var components = DateComponents(calendar: calendar)
        components.day = day
        components.weekOfMonth = weekOfMonth
        components.month = month
        components.year = year

        return DateComponentsFormatter.localizedString(from: components, unitsStyle: .full)
    }
}
