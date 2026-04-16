//
//  VC.DateTime.swift
//  AdaptyUIBulder
//
//  Created by Aleksei Valiano on 23.03.2026.
//

import Foundation

extension VC {
    enum DateTime: Sendable, Hashable {
        case date(Date)
        case fromStart(TimeInterval)
    }
}

extension VC.DateTime {
    func asDate(startAt: Date) -> Date {
        switch self {
        case let .date(date):
            date
        case let .fromStart(timeInterval):
            startAt.addingTimeInterval(timeInterval)
        }
    }
}

