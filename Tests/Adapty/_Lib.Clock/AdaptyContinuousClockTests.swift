//
//  AdaptyContinuousClockTests.swift
//  AdaptyTests
//
//  Created by OpenAI on 07.07.2026.
//

#if canImport(Testing)

@testable import Adapty
import Testing

extension ClockTests {
    struct AdaptyContinuousClockTests {
        @Test func nowAndDuration() {
            let start = AdaptyContinuousClock.Instant.now
            let end = start.advanced(by: .seconds(2))

            #expect(start.duration(to: end) == .seconds(2))
            #expect(end - start == .seconds(2))
            #expect(start < end)
            #expect(start <= end)
            #expect(end > start)
            #expect(end >= start)
        }

        @Test func nowIsMonotonic() {
            let first = AdaptyContinuousClock.now
            let second = AdaptyContinuousClock.now

            #expect(first <= second)
        }

        @Test func durationOperators() {
            let start = AdaptyContinuousClock.now

            #expect(start + .seconds(1) == start.advanced(by: .seconds(1)))
            #expect(start - .milliseconds(500) == start.advanced(by: .milliseconds(-500)))

            var value = start
            value += .seconds(1)
            #expect(value == start + .seconds(1))

            value -= .milliseconds(500)
            #expect(value == start + .milliseconds(500))
        }

        @Test func negativeDurationBetweenInstants() {
            let start = AdaptyContinuousClock.Instant(uptimeNanoseconds: 1_000)
            let end = AdaptyContinuousClock.Instant(uptimeNanoseconds: 500)

            #expect(start.duration(to: end) == .nanoseconds(-500))
            #expect(end - start == .nanoseconds(-500))
        }

        @Test func advancedByNegativeDuration() {
            let instant = AdaptyContinuousClock.Instant(uptimeNanoseconds: 1_000)

            #expect(instant.advanced(by: .nanoseconds(-200)) == AdaptyContinuousClock.Instant(uptimeNanoseconds: 800))
            #expect(instant - .nanoseconds(200) == AdaptyContinuousClock.Instant(uptimeNanoseconds: 800))
        }

        @Test func hashable() {
            let instant = AdaptyContinuousClock.now
            let same = instant

            #expect(instant == same)
            #expect(instant.hashValue == same.hashValue)
            #expect(Set([instant, same]).count == 1)
        }

        @Test func clockProperties() {
            let clock = AdaptyContinuousClock()

            #expect(clock.minimumResolution == .nanoseconds(1))
            #expect(clock.now <= AdaptyContinuousClock.now)
        }

        @Test func sleepUntilPastDeadlineReturnsImmediately() async throws {
            let clock = AdaptyContinuousClock()
            let deadline = clock.now - .milliseconds(1)

            try await clock.sleep(until: deadline)
        }

        @Test func advancedSaturatesAtUptimeBounds() {
            let minimum = AdaptyContinuousClock.Instant(uptimeNanoseconds: 0)
            let maximum = AdaptyContinuousClock.Instant(uptimeNanoseconds: UInt64.max)

            #expect(minimum.advanced(by: .nanoseconds(Int64.min)) == minimum)
            #expect(maximum.advanced(by: .nanoseconds(Int64.max)) == maximum)
        }

        @Test func durationSaturatesAtInt64Bounds() {
            let minimum = AdaptyContinuousClock.Instant(uptimeNanoseconds: 0)
            let maximum = AdaptyContinuousClock.Instant(uptimeNanoseconds: UInt64.max)

            #expect(minimum.duration(to: maximum) == .nanoseconds(Int64.max))
            #expect(maximum.duration(to: minimum) == .nanoseconds(Int64.min))
        }

    }
}
#endif
