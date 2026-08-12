//
//  AdaptyContinuousClock.swift
//  AdaptySDK
//
//  Created by OpenAI on 07.07.2026.
//

import Foundation
import Darwin

@usableFromInline
struct AdaptyContinuousClock: Sendable {
    @inlinable
    init() {}

    @inlinable
    static var now: Instant { .now }

    @inlinable
    var now: Instant { .now }

    @inlinable
    var minimumResolution: AdaptyDuration { .init(nanoseconds: 1) }

    @inlinable
    func sleep(
        until deadline: Instant
    ) async throws {
        try await Task.sleep(duration: now.duration(to: deadline))
    }
}

extension AdaptyContinuousClock {
    @usableFromInline
    struct Instant: Comparable, Hashable, Sendable {
        @usableFromInline
        let uptimeNanoseconds: UInt64

        @usableFromInline
        init(uptimeNanoseconds: UInt64) {
            self.uptimeNanoseconds = uptimeNanoseconds
        }

        @inlinable
        static var now: AdaptyContinuousClock.Instant {
            .init(uptimeNanoseconds: clock_gettime_nsec_np(CLOCK_MONOTONIC_RAW))
        }

        @inlinable
        func advanced(by duration: AdaptyDuration) -> AdaptyContinuousClock.Instant {
            .init(uptimeNanoseconds: Self.saturatingAdd(uptimeNanoseconds, duration.nanoseconds))
        }

        @inlinable
        func duration(to other: AdaptyContinuousClock.Instant) -> AdaptyDuration {
            .init(nanoseconds: Self.saturatingDistance(from: uptimeNanoseconds, to: other.uptimeNanoseconds))
        }

        @inlinable
        static func == (lhs: AdaptyContinuousClock.Instant, rhs: AdaptyContinuousClock.Instant) -> Bool {
            lhs.uptimeNanoseconds == rhs.uptimeNanoseconds
        }

        @inlinable
        static func < (lhs: AdaptyContinuousClock.Instant, rhs: AdaptyContinuousClock.Instant) -> Bool {
            lhs.uptimeNanoseconds < rhs.uptimeNanoseconds
        }

        @inlinable
        static func <= (lhs: AdaptyContinuousClock.Instant, rhs: AdaptyContinuousClock.Instant) -> Bool {
            lhs.uptimeNanoseconds <= rhs.uptimeNanoseconds
        }

        @inlinable
        static func > (lhs: AdaptyContinuousClock.Instant, rhs: AdaptyContinuousClock.Instant) -> Bool {
            lhs.uptimeNanoseconds > rhs.uptimeNanoseconds
        }

        @inlinable
        static func >= (lhs: AdaptyContinuousClock.Instant, rhs: AdaptyContinuousClock.Instant) -> Bool {
            lhs.uptimeNanoseconds >= rhs.uptimeNanoseconds
        }

        @inlinable
        func hash(into hasher: inout Hasher) {
            hasher.combine(uptimeNanoseconds)
        }
    }
}

extension AdaptyContinuousClock.Instant {
    @inlinable
    static func + (lhs: AdaptyContinuousClock.Instant, rhs: AdaptyDuration) -> AdaptyContinuousClock.Instant {
        lhs.advanced(by: rhs)
    }

    @inlinable
    static func - (lhs: AdaptyContinuousClock.Instant, rhs: AdaptyDuration) -> AdaptyContinuousClock.Instant {
        lhs.advanced(by: .zero - rhs)
    }

    @inlinable
    static func += (lhs: inout AdaptyContinuousClock.Instant, rhs: AdaptyDuration) {
        lhs = lhs + rhs
    }

    @inlinable
    static func -= (lhs: inout AdaptyContinuousClock.Instant, rhs: AdaptyDuration) {
        lhs = lhs - rhs
    }

    @inlinable
    static func - (lhs: AdaptyContinuousClock.Instant, rhs: AdaptyContinuousClock.Instant) -> AdaptyDuration {
        rhs.duration(to: lhs)
    }
}

extension AdaptyContinuousClock.Instant {
    @usableFromInline
    static func saturatingAdd(_ lhs: UInt64, _ rhs: Int64) -> UInt64 {
        if rhs >= 0 {
            let (result, overflow) = lhs.addingReportingOverflow(UInt64(rhs))
            return overflow ? UInt64.max : result
        } else {
            let (result, overflow) = lhs.subtractingReportingOverflow(rhs.magnitude)
            return overflow ? 0 : result
        }
    }

    @usableFromInline
    static func saturatingDistance(from lhs: UInt64, to rhs: UInt64) -> Int64 {
        let (positiveDistance, positiveOverflow) = rhs.subtractingReportingOverflow(lhs)
        if !positiveOverflow {
            let distance = positiveDistance
            return distance > UInt64(Int64.max) ? Int64.max : Int64(distance)
        } else {
            let (distance, _) = lhs.subtractingReportingOverflow(rhs)
            return distance > UInt64(Int64.max) ? Int64.min : -Int64(distance)
        }
    }
}
