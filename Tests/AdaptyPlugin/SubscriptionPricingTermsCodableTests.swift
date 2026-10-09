//
//  SubscriptionPricingTermsCodableTests.swift
//  AdaptyTests
//

@testable import Adapty
@testable import AdaptyPlugin
import Foundation
import Testing

@Suite("Plugin subscription pricing terms")
struct SubscriptionPricingTermsCodableTests {
    @available(macOS, introduced: 14, message: "JSONEncoder.encode(_:configuration:) requires macOS 14 or later.")
    @available(iOS, introduced: 17, message: "JSONEncoder.encode(_:configuration:) requires iOS 17 or later.")
    @available(tvOS, introduced: 17, message: "JSONEncoder.encode(_:configuration:) requires tvOS 17 or later.")
    @available(watchOS, introduced: 10, message: "JSONEncoder.encode(_:configuration:) requires watchOS 10 or later.")
    @Test("Terms encoding preserves prices, periods and unknown plans",
          arguments: ["monthly", "up_front", "future_plan"], [
              ("EUR", "€", Decimal(string: "9.99")!, "9,99 €", Decimal(string: "119.90")!, "119,90 €"),
              ("USD", "$", Decimal(string: "9.99")!, "$9.99", Decimal(string: "119.90")!, "$119.90"),
              ("EUR", nil, Decimal(string: "9.99")!, "9,99 €", Decimal(string: "119.90")!, "119,90 €"),
          ] as [(String, String?, Decimal, String, Decimal, String)])
    func encodeTerms(
        plan: String,
        currency: (
            code: String,
            symbol: String?,
            billingPrice: Decimal,
            localizedBillingPrice: String,
            commitmentPrice: Decimal,
            localizedCommitmentPrice: String
        )
    ) throws {
        let terms = AdaptySubscriptionPricingTerms(
            billingPlan: .init(rawValue: plan),
            billingPrice: currency.billingPrice,
            localizedBillingPrice: currency.localizedBillingPrice,
            billingPeriod: .init(1, .month),
            commitmentInfo: .init(
                price: currency.commitmentPrice,
                localizedPrice: currency.localizedCommitmentPrice,
                period: .init(12, .month)
            )
        )
        let encodingConfiguration = AdaptyProductEncodingConfiguration(
            price: .init(currencyCode: currency.code, currencySymbol: currency.symbol)
        )

        let actualJSON = try Json.encode(terms, configuration: encodingConfiguration, with: AdaptyPlugin.encoder)

        var billingPrice: [String: Any] = [
            "amount": NSDecimalNumber(decimal: currency.billingPrice),
            "currency_code": currency.code,
            "localized_string": currency.localizedBillingPrice,
        ]
        var commitmentPrice: [String: Any] = [
            "amount": NSDecimalNumber(decimal: currency.commitmentPrice),
            "currency_code": currency.code,
            "localized_string": currency.localizedCommitmentPrice,
        ]
        billingPrice["currency_symbol"] = currency.symbol
        commitmentPrice["currency_symbol"] = currency.symbol
        let expected: [String: Any] = [
            "billing_plan_id": plan,
            "billing_price": billingPrice,
            "billing_period": ["unit": "month", "number_of_units": 1],
            "commitment_info": [
                "price": commitmentPrice,
                "period": ["unit": "month", "number_of_units": 12],
            ],
        ]
        // Normalize key order before comparing the complete wire format, including extra fields.
        let expectedJSON = Json(deserilized: expected)
        #expect(actualJSON == expectedJSON)
    }

    @Test("Both product requests read plans only from subscription pricing terms",
          arguments: [
              (Json(##"{}"##), nil),
              (Json(##"{"billing_plan_id":null}"##), nil),
              (Json(##"{"subscription":null}"##), nil),
              (Json(##"{"subscription":{}}"##), nil),
              (Json(##"{"subscription":{"pricing_terms":null}}"##), nil),
              (Json(##"{"subscription":{"pricing_terms":{}}}"##), nil),
              (Json(##"{"subscription":{"pricing_terms":{"billing_plan_id":null}}}"##), nil),
              (Json(##"{"billing_plan_id":"monthly"}"##), nil),
              (Json(##"{"billing_plan_id":"monthly","subscription":{"pricing_terms":null}}"##), nil),
              (Json(##"{"billing_plan_id":"up_front","subscription":{"pricing_terms":{"billing_plan_id":"monthly"}}}"##), "monthly"),
              (Json(##"{"subscription":{"pricing_terms":{"billing_plan_id":"up_front"}}}"##), "up_front"),
              (Json(##"{"subscription":{"pricing_terms":{"billing_plan_id":"future_plan"}}}"##), "future_plan"),
          ] as [(Json, String?)])
    func requestPlanSelection(extra: Json, expected: String?) throws {
        let data = try productData(extra: extra)
        let paywall = try AdaptyPlugin.decoder.decode(Request.AdaptyPluginPaywallProduct.self, from: data)
        let promoted = try AdaptyPlugin.decoder.decode(Request.AdaptyPluginPromotedProduct.self, from: data)
        #expect(paywall.billingPlan?.rawValue == expected)
        #expect(promoted.billingPlan?.rawValue == expected)
        #expect(paywall.subscriptionOfferIdentifier == nil)
        #expect(promoted.subscriptionOfferIdentifier == nil)
    }

    @Test("Malformed subscription and plan fields are rejected",
          arguments: [
              Json(##"{"subscription":42}"##),
              Json(##"{"subscription":{"pricing_terms":"monthly"}}"##),
              Json(##"{"subscription":{"pricing_terms":{"billing_plan_id":42}}}"##),
          ])
    func invalidPlan(extra: Json) throws {
        let data = try productData(extra: extra)
        #expect(throws: DecodingError.self) {
            try AdaptyPlugin.decoder.decode(Request.AdaptyPluginPaywallProduct.self, from: data)
        }
        #expect(throws: DecodingError.self) {
            try AdaptyPlugin.decoder.decode(Request.AdaptyPluginPromotedProduct.self, from: data)
        }
    }

    @Test("Offer identifiers are decoded independently of pricing terms",
          arguments: [
              (Json(##"{"type":"introductory"}"##), .introductory, "monthly"),
              (Json(##"{"type":"promotional","id":"monthly-offer"}"##), .promotional("monthly-offer"), "monthly"),
              (Json(##"{"type":"win_back","id":"return-offer"}"##), .winBack("return-offer"), "monthly"),
              (Json(##"{"type":"introductory"}"##), .introductory, nil),
              (Json(##"{"type":"promotional","id":"promo-offer"}"##), .promotional("promo-offer"), nil),
              (Json(##"{"type":"win_back","id":"return-offer"}"##), .winBack("return-offer"), nil),
          ] as [(Json, AdaptySubscriptionOffer.Identifier, String?)])
    func offerAndPlan(identifier: Json, expected: AdaptySubscriptionOffer.Identifier, plan: String?) throws {
        var subscription: [String: Any] = [
            "offer": ["offer_identifier": try identifier.deserilized],
        ]
        if let plan {
            subscription["pricing_terms"] = ["billing_plan_id": plan]
        }
        let data = try productData(extra: Json(deserilized: ["subscription": subscription]))
        let paywall = try AdaptyPlugin.decoder.decode(Request.AdaptyPluginPaywallProduct.self, from: data)
        let promoted = try AdaptyPlugin.decoder.decode(Request.AdaptyPluginPromotedProduct.self, from: data)
        #expect(paywall.subscriptionOfferIdentifier == expected)
        #expect(promoted.subscriptionOfferIdentifier == expected)
        #expect(paywall.billingPlan?.rawValue == plan)
        #expect(promoted.billingPlan?.rawValue == plan)
    }

    private func productData(extra: Json) throws -> Data {
        var product: [String: Any] = [
            "purchase_intent_id": "com.example.yearly",
            "vendor_product_id": "com.example.yearly",
            "adapty_product_id": "product",
            "access_level_id": "premium",
            "product_type": "annual",
            "paywall_product_index": 0,
            "paywall_variation_id": "variation",
            "paywall_ab_test_name": "test",
            "paywall_name": "paywall",
        ]
        product.merge(try #require(extra.deserilized as? [String: Any])) { _, new in new }
        return Json(deserilized: product).data
    }
}
