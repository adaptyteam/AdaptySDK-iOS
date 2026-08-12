//
//  AdaptyDurationTests.swift
//  AdaptyTests
//
//  Created by OpenAI on 06.07.2026.
//

#if canImport(Testing)

@testable import Adapty
import Testing

struct AdaptyDurationTests {
    @Test func components() {
        let positive = AdaptyDuration(secondsComponent: 1, attosecondsComponent: 500_000_000_000_000_000)
        #expect(positive.components.seconds == 1)
        #expect(positive.components.attoseconds == 500_000_000_000_000_000)

        let negative = AdaptyDuration(secondsComponent: -1, attosecondsComponent: -500_000_000_000_000_000)
        #expect(negative.components.seconds == -1)
        #expect(negative.components.attoseconds == -500_000_000_000_000_000)
    }

    @Test func factories() {
        #expect(AdaptyDuration.seconds(2).components.seconds == 2)
        #expect(AdaptyDuration.seconds(2).components.attoseconds == 0)
        #expect(AdaptyDuration.seconds(1.5) == .milliseconds(1_500))
        #expect(AdaptyDuration.minutes(1) == .seconds(60))
        #expect(AdaptyDuration.minutes(1.5) == .seconds(90))
        #expect(AdaptyDuration.hours(1) == .minutes(60))
        #expect(AdaptyDuration.hours(1.5) == .minutes(90))
        #expect(AdaptyDuration.milliseconds(1.5) == .microseconds(1_500))
        #expect(AdaptyDuration.microseconds(1.5) == .nanoseconds(1_500))
        #expect(AdaptyDuration.nanoseconds(1_500_000_000) == .seconds(1.5))
    }

    @Test func factorySaturation() {
        #expect(AdaptyDuration.seconds(Int.max) == .nanoseconds(Int64.max))
        #expect(AdaptyDuration.seconds(Int.min) == .nanoseconds(Int64.min))
        #expect(AdaptyDuration.milliseconds(Int.max) == .nanoseconds(Int64.max))
        #expect(AdaptyDuration.microseconds(Int.min) == .nanoseconds(Int64.min))
        #expect(AdaptyDuration.minutes(Int.max) == .nanoseconds(Int64.max))
        #expect(AdaptyDuration.hours(Int.min) == .nanoseconds(Int64.min))
    }

    @Test func doubleFactorySpecialValues() {
        #expect(AdaptyDuration.seconds(Double.infinity) == .nanoseconds(Int64.max))
        #expect(AdaptyDuration.seconds(-Double.infinity) == .nanoseconds(Int64.min))
        #expect(AdaptyDuration.seconds(Double.nan) == .zero)
    }

    @Test func doubleFactoryRoundsToNearestNanosecond() {
        #expect(AdaptyDuration.seconds(0.000_000_001_4) == .nanoseconds(1))
        #expect(AdaptyDuration.seconds(0.000_000_001_5) == .nanoseconds(2))
        #expect(AdaptyDuration.seconds(-0.000_000_001_5) == .nanoseconds(-2))
    }

    @Test func arithmetic() {
        var duration = AdaptyDuration.seconds(2)
        duration += .milliseconds(500)
        #expect(duration == .seconds(2.5))

        duration -= .seconds(1)
        #expect(duration == .seconds(1.5))

        #expect(duration * 2 == .seconds(3))
        #expect(AdaptyDuration.seconds(3) / 2 == .seconds(1.5))
        #expect(AdaptyDuration.seconds(3) / AdaptyDuration.seconds(2) == 1.5)
    }

    @Test func arithmeticSaturation() {
        #expect(AdaptyDuration.nanoseconds(Int64.max) + .nanoseconds(1) == .nanoseconds(Int64.max))
        #expect(AdaptyDuration.nanoseconds(Int64.min) - .nanoseconds(1) == .nanoseconds(Int64.min))
        #expect(AdaptyDuration.seconds(1) * Int.max == .nanoseconds(Int64.max))
        #expect(AdaptyDuration.seconds(-1) * Int.max == .nanoseconds(Int64.min))
        #expect(AdaptyDuration.nanoseconds(Int64.min) / -1 == .nanoseconds(Int64.max))
    }

    @Test func timeIntervalConversion() {
        #expect(AdaptyDuration.milliseconds(1_500).asTimeInterval == 1.5)
        #expect(AdaptyDuration.milliseconds(-1_500).asTimeInterval == -1.5)
    }

    @Test func integerUnitConversions() {
        #expect(AdaptyDuration.milliseconds(1_500).asSeconds == 1)
        #expect(AdaptyDuration.milliseconds(1_500).asMilliseconds == 1_500)
        #expect(AdaptyDuration.nanoseconds(999_999).asMilliseconds == 0)
        #expect(AdaptyDuration.milliseconds(-1).asSeconds == 0)
        #expect(AdaptyDuration.milliseconds(-1).asMilliseconds == 0)
    }

    @Test func attosecondComponentRounding() {
        #expect(AdaptyDuration(secondsComponent: 0, attosecondsComponent: 499_999_999) == .zero)
        #expect(AdaptyDuration(secondsComponent: 0, attosecondsComponent: 500_000_000) == .nanoseconds(1))
        #expect(AdaptyDuration(secondsComponent: 0, attosecondsComponent: -500_000_000) == .nanoseconds(-1))
        #expect(AdaptyDuration(secondsComponent: 1, attosecondsComponent: -500_000_000_000_000_000) == .milliseconds(500))
    }

    @Test func comparisonAndDescription() {
        #expect(AdaptyDuration.seconds(-1) < .zero)
        #expect(AdaptyDuration.seconds(1.5).description == "1.5 seconds")
    }
}

#endif
