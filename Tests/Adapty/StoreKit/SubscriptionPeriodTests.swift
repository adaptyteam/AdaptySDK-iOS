//
//  SubscriptionPeriodTests.swift
//  AdaptyTests
//

@testable import Adapty
import Testing

@Suite("Subscription period normalization")
struct SubscriptionPeriodTests {
    @Test("Normalization converts both the unit and the number of units",
          arguments: [
              (AdaptySubscriptionPeriod(7, .day), AdaptySubscriptionPeriod(1, .week)),
              (AdaptySubscriptionPeriod(28, .day), AdaptySubscriptionPeriod(4, .week)),
              (AdaptySubscriptionPeriod(12, .month), AdaptySubscriptionPeriod(1, .year)),
              (AdaptySubscriptionPeriod(24, .month), AdaptySubscriptionPeriod(2, .year)),
          ])
    func normalize(period: AdaptySubscriptionPeriod, expected: AdaptySubscriptionPeriod) {
        #expect(period.normalize == expected)
    }

    @Test("Normalization preserves periods without an exact conversion",
          arguments: [
              AdaptySubscriptionPeriod(1, .day),
              AdaptySubscriptionPeriod(8, .day),
              AdaptySubscriptionPeriod(1, .month),
              AdaptySubscriptionPeriod(18, .month),
              AdaptySubscriptionPeriod(4, .week),
              AdaptySubscriptionPeriod(2, .year),
              AdaptySubscriptionPeriod(3, .unknown),
          ])
    func preservePeriod(period: AdaptySubscriptionPeriod) {
        #expect(period.normalize == period)
    }
}
