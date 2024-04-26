//
//  AdaptyProductSubscriptionPeriod+Extensions.swift
//
//
//  Created by Alexey Goncharov on 2023-01-24.
//

import Adapty
import Foundation

extension AdaptyProductSubscriptionPeriod {
    private func numberOfDays() -> Double {
        switch unit {
        case .day: return Double(numberOfUnits)
        case .week: return Double(numberOfUnits) * 7.0
        case .month: return Double(numberOfUnits) * 30.0
        case .year: return Double(numberOfUnits) * 365.0
        case .unknown: return 0.0
        }
    }

    private func numberOfWeeks() -> Double {
        switch unit {
        case .day: return Double(numberOfUnits) / 7.0
        case .week: return Double(numberOfUnits)
        case .month: return Double(numberOfUnits) * 4.0
        case .year: return Double(numberOfUnits) * 52.0
        case .unknown: return 0.0
        }
    }

    private func numberOfMonths() -> Double {
        switch unit {
        case .day: return Double(numberOfUnits) / 30.0
        case .week: return Double(numberOfUnits) / 4.0
        case .month: return Double(numberOfUnits)
        case .year: return Double(numberOfUnits) * 12.0
        case .unknown: return 0.0
        }
    }

    private func numberOfYears() -> Double {
        switch unit {
        case .day: return Double(numberOfUnits) / 365.0
        case .week: return Double(numberOfUnits) / 52.0
        case .month: return Double(numberOfUnits) / 12.0
        case .year: return Double(numberOfUnits)
        case .unknown: return 0.0
        }
    }

    func numberOfPeriods(_ period: AdaptyPeriodUnit) -> Double {
        switch period {
        case .day: return numberOfDays()
        case .week: return numberOfWeeks()
        case .month: return numberOfMonths()
        case .year: return numberOfYears()
        case .unknown: return 0.0
        }
    }
}
