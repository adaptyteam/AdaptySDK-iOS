//
//  UIBuilderPricingTermsTests.swift
//  AdaptyTests
//

@testable import Adapty
@testable import AdaptyUIBuilder
import Foundation
import JavaScriptCore
import Testing

@Suite("UIBuilder subscription pricing terms")
struct UIBuilderPricingTermsTests {
    @MainActor
    @Test("SDK pricing terms preserve plan identifiers, prices and raw periods in JavaScript",
          arguments: [AdaptySubscriptionBillingPlan.monthly, .upFront, .init(rawValue: "future_plan")])
    func pricingTermsInJavaScript(plan: AdaptySubscriptionBillingPlan) throws {
        let isUpFront = plan == .upFront
        let priceFormatStyle = Decimal.FormatStyle.Currency(code: "EUR", locale: Locale(identifier: "de_DE"))
        let terms: AdaptySubscriptionPricingTerms
        if isUpFront {
            // Covers factory output, not StoreKit plan selection or fallback availability.
            terms = try #require(.upFront(
                price: 100,
                localizedPrice: "100,00 €",
                subscriptionPeriod: .init(1, .year)
            ))
        } else {
            // Unknown identifiers are preserved by the mapper; this does not imply purchasability.
            terms = .init(
                billingPlan: plan,
                billingPrice: try #require(Decimal(string: "9.99")),
                localizedBillingPrice: "9,99 €",
                billingPeriod: .init(1, .month),
                commitmentInfo: .init(
                    price: try #require(Decimal(string: "119.88")),
                    localizedPrice: "119,88 €",
                    period: plan == .monthly ? .init(12, .month) : .init(1, .year)
                )
            )
        }

        let subscription = VC.FlowConstants.ProductSubscriptionConstants(
            groupIdentifier: "group",
            period: .init(unit: "year", numberOfUnits: 1),
            localizedPeriod: "1 год",
            pricingTerms: terms.asUIBuilderPricingTerms(priceFormatStyle: priceFormatStyle),
            offer: nil
        )
        let context = try #require(JSContext())
        VS.JSState.setProductConstants([
            product(
                subscription: subscription,
                amount: isUpFront ? 100 : 119.88,
                localizedPrice: isUpFront ? "100,00 €" : "119,88 €"
            ),
        ], final: true, in: context)
        let jsTerms = try #require(context.evaluateScript("SDKProducts.yearly.subscription.pricingTerms"))

        try expectString(jsTerms.forProperty("billingPlanId"), equals: plan.rawValue)
        let billingPrice = try #require(jsTerms.forProperty("billingPrice"))
        try expectNumber(billingPrice.forProperty("amount"), equals: isUpFront ? 100 : 9.99)
        try expectString(billingPrice.forProperty("localizedString"), equals: isUpFront ? "100,00 €" : "9,99 €")
        try expectString(billingPrice.forProperty("currencyCode"), equals: "EUR")
        try expectString(billingPrice.forProperty("currencySymbol"), equals: "€")
        try expectString(jsTerms.forProperty("billingPeriod")?.forProperty("unit"), equals: isUpFront ? "year" : "month")
        try expectNumber(jsTerms.forProperty("billingPeriod")?.forProperty("numberOfUnits"), equals: 1)

        let commitment = try #require(jsTerms.forProperty("commitmentInfo"))
        let commitmentPrice = try #require(commitment.forProperty("price"))
        try expectNumber(commitmentPrice.forProperty("amount"), equals: isUpFront ? 100 : 119.88)
        try expectString(commitmentPrice.forProperty("localizedString"), equals: isUpFront ? "100,00 €" : "119,88 €")
        try expectString(commitmentPrice.forProperty("currencyCode"), equals: "EUR")
        try expectString(commitmentPrice.forProperty("currencySymbol"), equals: "€")
        try expectString(commitment.forProperty("period")?.forProperty("unit"), equals: plan == .monthly ? "month" : "year")
        try expectNumber(commitment.forProperty("period")?.forProperty("numberOfUnits"), equals: plan == .monthly ? 12 : 1)
        #expect(context.evaluateScript("SDKProducts.yearly.subscription.offer === null")?.toBool() == true)
        #expect(context.exception == nil)
    }

    @MainActor
    @Test("An absent subscription constant is serialized as JavaScript null")
    func absentSubscriptionInJavaScript() throws {
        let context = try #require(JSContext())
        VS.JSState.setProductConstants([product(subscription: nil)], final: true, in: context)
        #expect(context.evaluateScript("SDKProducts.yearly.subscription === null")?.toBool() == true)
        #expect(context.exception == nil)
    }

    private func expectString(
        _ value: JSValue?, equals expected: String,
        sourceLocation: SourceLocation = #_sourceLocation
    ) throws {
        let value = try #require(value, sourceLocation: sourceLocation)
        try #require(value.isString, sourceLocation: sourceLocation)
        #expect(value.toString() == expected, sourceLocation: sourceLocation)
    }

    private func expectNumber(
        _ value: JSValue?, equals expected: Double,
        sourceLocation: SourceLocation = #_sourceLocation
    ) throws {
        let value = try #require(value, sourceLocation: sourceLocation)
        try #require(value.isNumber, sourceLocation: sourceLocation)
        #expect(value.toDouble() == expected, sourceLocation: sourceLocation)
    }

    private func product(
        subscription: VC.FlowConstants.ProductSubscriptionConstants?,
        amount: Double = 100,
        localizedPrice: String = "100,00 €"
    ) -> VC.FlowConstants.ProductConstants {
        .init(
            flowProductId: "yearly",
            adaptyProductId: "product",
            adaptyAccessLevelId: "premium",
            adaptyProductType: "annual",
            paywallVariationId: "variation",
            paywallName: "paywall",
            localizedDescription: "Description",
            localizedTitle: "Title",
            isFamilyShareable: false,
            regionCode: "DE",
            price: .init(amount: amount, currencyCode: "EUR", currencySymbol: "€", localizedString: localizedPrice),
            subscription: subscription
        )
    }
}
