//
//  Date.ComponentsFormatStyle+StoreKit.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 30.10.2026.
//


import StoreKit

extension Date.ComponentsFormatStyle {
    func localized(period: AdaptySubscriptionPeriod, numberOfPeriods: Int = 1) -> String? {
        let countUnits = period.numberOfUnits * numberOfPeriods
        switch period.unit {
        case .day:
            if numberOfPeriods == 1, countUnits == 7 { return localizedComponents(weekOfMonth: 1) }
            return localizedComponents(day: countUnits)
        case .week:
            return localizedComponents(weekOfMonth: countUnits)
        case .month:
            return localizedComponents(month: countUnits)
        case .year:
            return localizedComponents(year: countUnits)
        default:
            return nil
        }
    }

    private func localizedComponents(day: Int? = nil, weekOfMonth: Int? = nil, month: Int? = nil, year: Int? = nil) -> String? {
        var calendar = Calendar.current
        calendar.locale = locale

        var components = DateComponents(calendar: calendar)
        components.day = day
        components.weekOfMonth = weekOfMonth
        components.month = month
        components.year = year

        return DateComponentsFormatter.localizedString(from: components, unitsStyle: .full)
    }
}
