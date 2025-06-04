//
//  TaskDuration.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 12.09.2024
//

import Foundation

@usableFromInline
enum TaskDuration: Comparable, Sendable {
    case never
    case now
    case nanoseconds(UInt64)
    case milliseconds(UInt64)
    case seconds(UInt64)
    case minutes(UInt64)
    case hours(UInt64)

    @inlinable
    init(_ seconds: TimeInterval) {
        self = .nanoseconds(UInt64(seconds * 1_000_000_000))
    }

    @inlinable
    var asTimeInterval: TimeInterval {
        switch self {
        case .never:
            Double.nan
        case .now:
            0
        case let .nanoseconds(nanoseconds):
            Double(nanoseconds) / 1_000_000_000
        case let .milliseconds(milliseconds):
            Double(milliseconds) / 1_000
        case let .seconds(seconds):
            Double(seconds)
        case let .minutes(minutes):
            Double(minutes * 60)
        case let .hours(hours):
            Double(hours * 60 * 60)
        }
    }

    @inlinable
    var asMilliseconds: UInt64 {
        switch self {
        case .never:
            UInt64.max
        case .now:
            0
        case let .nanoseconds(nanoseconds):
            nanoseconds / 1_000_000
        case let .milliseconds(milliseconds):
            milliseconds
        case let .seconds(seconds):
            seconds * 1_000
        case let .minutes(minutes):
            minutes * 60 * 1_000
        case let .hours(hours):
            hours * 60 * 60 * 1_000
        }
    }
    
    @inlinable
    var asNanoseconds: UInt64 {
        switch self {
        case .never:
            UInt64.max
        case .now:
            0
        case let .nanoseconds(nanoseconds):
            nanoseconds
        case let .milliseconds(milliseconds):
            milliseconds * 1_000_000
        case let .seconds(seconds):
            seconds * 1_000_000_000
        case let .minutes(minutes):
            minutes * 60 * 1_000_000_000
        case let .hours(hours):
            hours * 60 * 60 * 1_000_000_000
        }
    }

    @usableFromInline
    static func + (lhs: TaskDuration, rhs: TaskDuration) -> TaskDuration {
        let (nanoseconds, didOverflow): (UInt64, Bool) = lhs.asNanoseconds.addingReportingOverflow(rhs.asNanoseconds)
        return didOverflow ? .never : .nanoseconds(nanoseconds)
    }

    @usableFromInline
    static func - (lhs: TaskDuration, rhs: TaskDuration) -> TaskDuration {
        let (nanoseconds, didOverflow): (UInt64, Bool) = lhs.asNanoseconds.subtractingReportingOverflow(rhs.asNanoseconds)
        return didOverflow ? .now : .nanoseconds(nanoseconds)
    }

    @usableFromInline
    static func < (lhs: TaskDuration, rhs: TaskDuration) -> Bool {
        lhs.asNanoseconds < rhs.asNanoseconds
    }
}

func min(_ a: TaskDuration, _ b: TaskDuration) -> TaskDuration {
    a.asNanoseconds <= b.asNanoseconds ? a : b
}

func max(_ a: TaskDuration, _ b: TaskDuration) -> TaskDuration {
    a.asNanoseconds <= b.asNanoseconds ? a : b
}
