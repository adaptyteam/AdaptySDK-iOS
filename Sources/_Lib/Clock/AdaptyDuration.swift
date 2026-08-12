//
//  AdaptyDuration.swift
//  AdaptySDK
//
//  Created by OpenAI on 06.07.2026.
//

import Foundation

@usableFromInline
struct AdaptyDuration: Sendable, Hashable {


    @usableFromInline
    let nanoseconds: Int64

    @usableFromInline
    init(nanoseconds: Int64) {
        self.nanoseconds = nanoseconds
    }

    init(secondsComponent: Int64, attosecondsComponent: Int64) {
        self.nanoseconds = Self.saturatingAdd(
            Self.saturatingMultiply(secondsComponent, by: 1_000_000_000),
            Self.nanoseconds(fromAttoseconds: attosecondsComponent)
        )
    }

    var components: (seconds: Int64, attoseconds: Int64) {
        let seconds = nanoseconds / 1_000_000_000
        let nanosecondsRemainder = nanoseconds % 1_000_000_000
        return (
            seconds: seconds,
            attoseconds: nanosecondsRemainder * 1_000_000_000
        )
    }

    @inlinable
    var asTimeInterval: TimeInterval {
        TimeInterval(nanoseconds) / 1_000_000_000
    }

    @inlinable
    var asSeconds: UInt64 {
        guard nanoseconds > 0 else { return 0 }
        return UInt64(nanoseconds / 1_000_000_000)
    }

    @inlinable
    var asMilliseconds: UInt64 {
        guard nanoseconds > 0 else { return 0 }
        return UInt64(nanoseconds / 1_000_000)
    }

    static func hours<T: BinaryInteger>(_ hours: T) -> AdaptyDuration {
        .init(nanoseconds: Self.saturatingMultiply(Self.clampedInt64(hours), by: 3_600_000_000_000))
    }

    static func hours(_ hours: Double) -> AdaptyDuration {
        .init(nanoseconds: Self.nanoseconds(from: hours, scale: 3_600_000_000_000))
    }

    static func minutes<T: BinaryInteger>(_ minutes: T) -> AdaptyDuration {
        .init(nanoseconds: Self.saturatingMultiply(Self.clampedInt64(minutes), by: 60_000_000_000))
    }

    static func minutes(_ minutes: Double) -> AdaptyDuration {
        .init(nanoseconds: Self.nanoseconds(from: minutes, scale: 60_000_000_000))
    }

    static func seconds<T: BinaryInteger>(_ seconds: T) -> AdaptyDuration {
        .init(nanoseconds: Self.saturatingMultiply(Self.clampedInt64(seconds), by: 1_000_000_000))
    }

    static func seconds(_ seconds: Double) -> AdaptyDuration {
        .init(nanoseconds: Self.nanoseconds(from: seconds, scale: 1_000_000_000))
    }

    static func milliseconds<T: BinaryInteger>(_ milliseconds: T) -> AdaptyDuration {
        .init(nanoseconds: Self.saturatingMultiply(Self.clampedInt64(milliseconds), by: 1_000_000))
    }

    static func milliseconds(_ milliseconds: Double) -> AdaptyDuration {
        .init(nanoseconds: Self.nanoseconds(from: milliseconds, scale: 1_000_000))
    }

    static func microseconds<T: BinaryInteger>(_ microseconds: T) -> AdaptyDuration {
        .init(nanoseconds: Self.saturatingMultiply(Self.clampedInt64(microseconds), by: 1_000))
    }

    static func microseconds(_ microseconds: Double) -> AdaptyDuration {
        .init(nanoseconds: Self.nanoseconds(from: microseconds, scale: 1_000))
    }

    static func nanoseconds<T: BinaryInteger>(_ nanoseconds: T) -> AdaptyDuration {
        .init(nanoseconds: Self.clampedInt64(nanoseconds))
    }

    static func nanoseconds(_ nanoseconds: Double) -> AdaptyDuration {
        .init(nanoseconds: Self.nanoseconds(from: nanoseconds, scale: 1))
    }
}

extension AdaptyDuration {
    @inlinable
    static func == (lhs: AdaptyDuration, rhs: AdaptyDuration) -> Bool {
        lhs.nanoseconds == rhs.nanoseconds
    }
}

extension AdaptyDuration: Comparable {
    @inlinable
    static func < (lhs: AdaptyDuration, rhs: AdaptyDuration) -> Bool {
        lhs.nanoseconds < rhs.nanoseconds
    }
}

extension AdaptyDuration: AdditiveArithmetic {
    @inlinable
    static var zero: AdaptyDuration {
        .init(nanoseconds: 0)
    }

    @usableFromInline
    static func + (lhs: AdaptyDuration, rhs: AdaptyDuration) -> AdaptyDuration {
        .init(nanoseconds: saturatingAdd(lhs.nanoseconds, rhs.nanoseconds))
    }

    @usableFromInline
    static func - (lhs: AdaptyDuration, rhs: AdaptyDuration) -> AdaptyDuration {
        .init(nanoseconds: saturatingSubtract(lhs.nanoseconds, rhs.nanoseconds))
    }

    @usableFromInline
    static func += (lhs: inout AdaptyDuration, rhs: AdaptyDuration) {
        lhs = lhs + rhs
    }

    @usableFromInline
    static func -= (lhs: inout AdaptyDuration, rhs: AdaptyDuration) {
        lhs = lhs - rhs
    }
}

extension AdaptyDuration {
    static func / (lhs: AdaptyDuration, rhs: Double) -> AdaptyDuration {
        precondition(rhs != 0 && rhs.isFinite, "Cannot divide AdaptyDuration by zero or a non-finite value.")
        return .nanoseconds((Double(lhs.nanoseconds) / rhs).rounded())
    }

    static func /= (lhs: inout AdaptyDuration, rhs: Double) {
        lhs = lhs / rhs
    }

    static func / <T: BinaryInteger>(lhs: AdaptyDuration, rhs: T) -> AdaptyDuration {
        precondition(rhs != 0, "Cannot divide AdaptyDuration by zero.")
        return .init(nanoseconds: saturatingDivide(lhs.nanoseconds, by: clampedInt64(rhs)))
    }

    static func /= <T: BinaryInteger>(lhs: inout AdaptyDuration, rhs: T) {
        lhs = lhs / rhs
    }

    @inlinable
    static func / (lhs: AdaptyDuration, rhs: AdaptyDuration) -> Double {
        Double(lhs.nanoseconds) / Double(rhs.nanoseconds)
    }

    static func * (lhs: AdaptyDuration, rhs: Double) -> AdaptyDuration {
        .nanoseconds((Double(lhs.nanoseconds) * rhs).rounded())
    }

    static func * <T: BinaryInteger>(lhs: AdaptyDuration, rhs: T) -> AdaptyDuration {
        .init(nanoseconds: saturatingMultiply(lhs.nanoseconds, by: clampedInt64(rhs)))
    }

    static func *= <T: BinaryInteger>(lhs: inout AdaptyDuration, rhs: T) {
        lhs = lhs * rhs
    }
}

extension AdaptyDuration: CustomStringConvertible {
    @usableFromInline
    var description: String {
        (Double(nanoseconds) / 1_000_000_000).description + " seconds"
    }
}

private extension AdaptyDuration {
    static func clampedInt64<T: BinaryInteger>(_ value: T) -> Int64 {
        if let value = Int64(exactly: value) {
            return value
        }
        return value < 0 ? Int64.min : Int64.max
    }

    static func nanoseconds(from value: Double, scale: Int64) -> Int64 {
        if value.isNaN { return 0 }
        if value == .infinity { return Int64.max }
        if value == -.infinity { return Int64.min }

        let scaled = (value * Double(scale)).rounded()
        guard scaled < Double(Int64.max) else { return Int64.max }
        guard scaled > Double(Int64.min) else { return Int64.min }
        return Int64(scaled)
    }

    static func nanoseconds(fromAttoseconds value: Int64) -> Int64 {
        let quotient = value / 1_000_000_000
        let remainder = value % 1_000_000_000

        if abs(remainder) >= 1_000_000_000 / 2 {
            return saturatingAdd(quotient, remainder > 0 ? 1 : -1)
        } else {
            return quotient
        }
    }

    static func saturatingAdd(_ lhs: Int64, _ rhs: Int64) -> Int64 {
        let (result, overflow) = lhs.addingReportingOverflow(rhs)
        guard overflow else { return result }
        return lhs >= 0 ? Int64.max : Int64.min
    }

    static func saturatingSubtract(_ lhs: Int64, _ rhs: Int64) -> Int64 {
        let (result, overflow) = lhs.subtractingReportingOverflow(rhs)
        guard overflow else { return result }
        return lhs >= 0 ? Int64.max : Int64.min
    }

    static func saturatingMultiply(_ lhs: Int64, by rhs: Int64) -> Int64 {
        let (result, overflow) = lhs.multipliedReportingOverflow(by: rhs)
        guard overflow else { return result }
        return (lhs < 0) == (rhs < 0) ? Int64.max : Int64.min
    }

    static func saturatingDivide(_ lhs: Int64, by rhs: Int64) -> Int64 {
        if lhs == Int64.min, rhs == -1 { return Int64.max }
        return lhs / rhs
    }
}
