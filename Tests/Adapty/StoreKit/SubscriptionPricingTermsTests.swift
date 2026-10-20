//
//  SubscriptionPricingTermsTests.swift
//  AdaptyTests
//

@testable import Adapty
import Foundation
import Testing

@Suite("Subscription pricing terms")
struct SubscriptionPricingTermsTests {
    @Test("Up-front factory uses the full price and period for both billing and commitment",
          arguments: [
              ("119.90", "119,90 €", AdaptySubscriptionPeriod(1, .year)),
              ("29.99", "$29.99", AdaptySubscriptionPeriod(3, .month)),
          ])
    func upFrontTerms(amount: String, localizedPrice: String, period: AdaptySubscriptionPeriod) throws {
        let price = try #require(Decimal(string: amount))
        let terms = try #require(AdaptySubscriptionPricingTerms.upFront(
            price: price,
            localizedPrice: localizedPrice,
            subscriptionPeriod: period
        ))

        #expect(terms.billingPlan == .upFront)
        #expect(terms.billingPrice == price)
        #expect(terms.localizedBillingPrice == localizedPrice)
        #expect(terms.billingPeriod == period)
        #expect(terms.commitmentInfo.price == price)
        #expect(terms.commitmentInfo.localizedPrice == localizedPrice)
        #expect(terms.commitmentInfo.period == period)
    }
}
