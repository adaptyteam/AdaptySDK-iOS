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
              ("119.90", "119,90 €", AdaptySubscriptionPeriod(1, .year), "EUR", "de_DE"),
              ("29.99", "$29.99", AdaptySubscriptionPeriod(3, .month), "USD", "en_US"),
          ])
    func upFrontTerms(
        amount: String,
        localizedPrice: String,
        period: AdaptySubscriptionPeriod,
        currencyCode: String,
        localeIdentifier: String
    ) throws {
        let price = try #require(Decimal(string: amount))
        let locale = Locale(identifier: localeIdentifier)
        let terms = try #require(AdaptySubscriptionPricingTerms.upFront(
            price: price,
            localizedPrice: localizedPrice,
            subscriptionPeriod: period,
            priceFormatStyle: .init(code: currencyCode, locale: locale),
            periodFormatStyle: .init(style: .wide, fields: [.year, .month, .week, .day]).locale(locale)
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
