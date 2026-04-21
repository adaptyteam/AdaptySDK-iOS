//
//  VC.TimerConverter.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 20.04.2026.
//

import Foundation

extension VC {
    enum TimerConverter: Converter {
        case days(String)
        case hours(String)
        case minutes(String)
        case seconds(String)
        case deciseconds
        case centiseconds
        case milliseconds

        case totalDays(String)
        case totalHours(String)
        case totalMinutes(String)
        case totalSeconds(String)
        case totalMilliseconds(String)
    }
}

extension VC.TimerConverter {
    func toString(_ value: Any) -> String? {
        switch value {
        case is Bool:
            nil
        case let value as NSNumber:
            toString(timeinterval: value.doubleValue)
        default:
            nil
        }
    }

    @inlinable
    func toString(timeinterval: TimeInterval) -> String {
        let timeinterval = max(0, timeinterval)
        return switch self {
        case let .days(format):
            String(format: format, Int(timeinterval) / 86400)
        case let .hours(format):
            String(format: format, Int(timeinterval) % 86400 / 3600)
        case let .minutes(format):
            String(format: format, Int(timeinterval) % 3600 / 60)
        case let .seconds(format):
            String(format: format, Int(timeinterval) % 60)
        case .deciseconds:
            String(format: "%d", Int(timeinterval * 10) % 10)
        case .centiseconds:
            String(format: "%02d", Int(timeinterval * 100) % 100)
        case .milliseconds:
            String(format: "%03d", Int(timeinterval * 1000) % 1000)
        case let .totalDays(format):
            String(format: format, Int(timeinterval / 86400))
        case let .totalHours(format):
            String(format: format, Int(timeinterval / 3600))
        case let .totalMinutes(format):
            String(format: format, Int(timeinterval / 60))
        case let .totalSeconds(format):
            String(format: format, Int(timeinterval))
        case let .totalMilliseconds(format):
            String(format: format, Int(timeinterval * 1000))
        }
    }

    var updatesPerSecond: Int {
        let x: Int
        switch self {
        case .deciseconds: return 10
        case .centiseconds: return 100
        case .milliseconds, .totalMilliseconds: return 120
        default: return 1
        }
    }
}

