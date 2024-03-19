//
//  Locale+Extensions.swift
//
//
//  Created by Aleksei Valiano on 01.02.2024
//
//

import StoreKit

extension Locale: AdaptyExtended {}

extension AdaptyExtension where Extended == Locale {
    var currencyCode: String? {
        guard #available(macOS 13, iOS 16, tvOS 16, watchOS 9, visionOS 1.0, *) else {
            return this.currencyCode
        }
        return this.currency?.identifier
    }

    var regionCode: String? {
        guard #available(macOS 13, iOS 16, tvOS 16, watchOS 9, visionOS 1.0, *) else {
            return this.regionCode
        }
        return this.region?.identifier
    }

    func localized(price: NSNumber) -> String? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = this
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        return formatter.string(from: price)
    }

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
        calendar.locale = this

        var components = DateComponents(calendar: calendar)
        components.day = day
        components.weekOfMonth = weekOfMonth
        components.month = month
        components.year = year

        return DateComponentsFormatter.localizedString(from: components, unitsStyle: .full)
    }
}
