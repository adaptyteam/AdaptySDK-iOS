//
//  PaywallProductPricingTermsTests.swift
//  AdaptyTests
//

@testable import Adapty
import Foundation
import Testing

@Suite("Paywall product pricing terms")
struct PaywallProductPricingTermsTests {
    private typealias Terms = AdaptyFlowPaywall.ProducPricingTerms

    @Test("Absent, null and empty alternatives retain the root up-front configuration",
          arguments: ["absent", "null", "empty"], ["absent", "null", "true", "false"])
    func legacyTerms(array: String, eligibility: String) throws {
        var fields: [String: Any] = [
            "billing_plan_id": "monthly",
            "promotional_offer_id": "root-promo",
            "win_back_offer_id": "root-winback",
        ]
        if array == "null" { fields["pricing_terms"] = NSNull() }
        if array == "empty" { fields["pricing_terms"] = [Any]() }
        if eligibility == "null" { fields["promotional_offer_eligibility"] = NSNull() }
        if eligibility == "true" { fields["promotional_offer_eligibility"] = true }
        if eligibility == "false" { fields["promotional_offer_eligibility"] = false }
        let reference = try decode(fields)
        #expect(reference.pricingTerms == [Terms(
            billingPlan: .upFront,
            promotionalOfferId: eligibility == "false" ? nil : "root-promo",
            winBackOfferId: "root-winback"
        )])
        let restored = try Json.encode(reference).decode(DecodedReference.self).value
        #expect(restored == reference)
    }

    @Test("Storage preserves the prepared sequence and effective root offers",
          arguments: [false, true], [false, true])
    func roundTrip(empty: Bool, promotionalEligible: Bool) throws {
        let terms: [Terms] = empty ? [] : [
            .init(billingPlan: .monthly, promotionalOfferId: "monthly-promo", winBackOfferId: nil),
            .init(billingPlan: .monthly, promotionalOfferId: nil, winBackOfferId: "monthly-winback"),
            .init(billingPlan: .upFront, promotionalOfferId: "root-promo", winBackOfferId: "root-winback"),
        ]
        let reference = try decode([
            "pricing_terms": try Json.encode(terms).deserilized,
            "promotional_offer_id": "root-promo",
            "win_back_offer_id": "root-winback",
            "promotional_offer_eligibility": promotionalEligible,
        ])
        let rootTerms = Terms(
            billingPlan: .upFront,
            promotionalOfferId: promotionalEligible ? "root-promo" : nil,
            winBackOfferId: "root-winback"
        )
        let expected = terms.last == rootTerms ? terms : terms + [rootTerms]
        #expect(reference.pricingTerms == expected)
        let encoded = try Json.encode(reference)
        let object = try #require(encoded.deserilized as? [String: Any])
        #expect(object["promotional_offer_id"] == nil)
        #expect(object["win_back_offer_id"] == nil)
        #expect(object["promotional_offer_eligibility"] == nil)
        #expect(object["billing_plan_id"] == nil)
        let array = try #require(object["pricing_terms"] as? [[String: Any]])
        #expect(array.count == expected.count)
        let restored = try encoded.decode(DecodedReference.self).value
        #expect(restored == reference)
        let restoredAgain = try Json.encode(restored).decode(DecodedReference.self).value
        #expect(restoredAgain == reference)
    }

    @Test("Malformed alternatives fail decoding instead of becoming a fallback",
          arguments: ["{}", "42", "[null]", "[{}]", "[{\"billing_plan_id\":null}]", "[{\"billing_plan_id\":42}]", "[{\"billing_plan_id\":\"monthly\",\"promotional_offer_id\":false}]"])
    func invalidTerms(json: String) throws {
        let value = try Json(data: Data(json.utf8)).deserilized
        #expect(throws: (any Error).self) {
            try decode(["pricing_terms": value, "promotional_offer_id": "root-promo"])
        }
    }

    @Test("Unknown plan IDs and null offers survive decoding")
    func unknownPlan() throws {
        let reference = try decode(["pricing_terms": [[
            "billing_plan_id": "future_plan",
            "promotional_offer_id": NSNull(),
            "win_back_offer_id": NSNull(),
        ]]])
        #expect(reference.pricingTerms == [.init(
            billingPlan: .init(rawValue: "future_plan"), promotionalOfferId: nil, winBackOfferId: nil
        ), .default])
    }

    // Offer selection now runs inside getPaywallProducts with concrete StoreKit dependencies.
    // These unit tests cover the production decoder and storage, not StoreKit selection or eligibility.
    @Test("Prepared terms preserve ordering, root offers and repeated round trips",
          arguments: PreparationCase.all)
    func preparedTerms(test: PreparationCase) throws {
        var fields: [String: Any] = [
            "pricing_terms": try Json.encode(test.terms).deserilized,
            "promotional_offer_eligibility": test.rootPromoEligible,
        ]
        fields["promotional_offer_id"] = test.rootPromo
        fields["win_back_offer_id"] = test.rootWinBack
        let reference = try decode(fields)
        #expect(reference.pricingTerms == test.expected)

        let restored = try Json.encode(reference).decode(DecodedReference.self).value
        #expect(restored == reference)
        #expect(restored.pricingTerms == test.expected)
        let restoredAgain = try Json.encode(restored).decode(DecodedReference.self).value
        #expect(restoredAgain == reference)
    }

    struct PreparationCase: Sendable, CustomStringConvertible {
        var description: String { name }

        let name: String
        let terms: [AdaptyFlowPaywall.ProducPricingTerms]
        var rootPromo: String? = nil
        var rootWinBack: String? = nil
        var rootPromoEligible = true
        let expected: [AdaptyFlowPaywall.ProducPricingTerms]

        static var all: [Self] {
            let monthly = Terms(billingPlan: .monthly, promotionalOfferId: "monthly-promo", winBackOfferId: nil)
            let secondMonthly = Terms(billingPlan: .monthly, promotionalOfferId: "second-promo", winBackOfferId: nil)
            let upfront = Terms(billingPlan: .upFront, promotionalOfferId: "upfront-promo", winBackOfferId: nil)
            let root = Terms(billingPlan: .upFront, promotionalOfferId: "root-promo", winBackOfferId: "root-winback")
            let rootWinBack = Terms(billingPlan: .upFront, promotionalOfferId: nil, winBackOfferId: "root-winback")
            return [
                .init(name: "empty configuration gets upfront", terms: [], expected: [.default]),
                .init(name: "monthly gets empty root upfront", terms: [monthly], expected: [monthly, .default]),
                .init(name: "existing empty upfront is not duplicated", terms: [monthly, .default], expected: [monthly, .default]),
                .init(name: "upfront offers do not acquire an empty tail", terms: [upfront], expected: [upfront]),
                .init(name: "different root offers are preserved", terms: [upfront], rootPromo: "root-promo", rootWinBack: "root-winback", expected: [upfront, root]),
                .init(name: "matching root is not duplicated", terms: [monthly, root], rootPromo: "root-promo", rootWinBack: "root-winback", expected: [monthly, root]),
                .init(name: "repeated plans preserve order and offers", terms: [monthly, secondMonthly], rootPromo: "root-promo", rootWinBack: "root-winback", expected: [monthly, secondMonthly, root]),
                .init(name: "explicit upfront keeps its position", terms: [upfront, monthly], expected: [upfront, monthly, .default]),
                .init(name: "legacy flag does not filter explicit matching offer", terms: [root], rootPromo: "root-promo", rootWinBack: "root-winback", rootPromoEligible: false, expected: [root, rootWinBack]),
                .init(name: "legacy flag removes only root promo", terms: [monthly], rootPromo: "root-promo", rootPromoEligible: false, expected: [monthly, .default]),
            ]
        }
    }

    private func decode(_ extra: [String: Any]) throws -> AdaptyFlowPaywall.ProductReference {
        var fields: [String: Any] = [
            "vendor_product_id": "com.example.yearly",
            "adapty_product_id": "product",
            "flow_product_id": "annual",
            "access_level_id": "premium",
            "product_type": "annual",
        ]
        fields.merge(extra) { _, new in new }
        return try Json(deserilized: fields).decode(DecodedReference.self).value
    }

    private struct DecodedReference: Decodable {
        let value: AdaptyFlowPaywall.ProductReference

        init(from decoder: any Decoder) throws {
            value = try AdaptyFlowPaywall.ProductReference(
                from: decoder.container(keyedBy: AdaptyFlowPaywall.ProductReference.CodingKeys.self),
                index: 0
            )
        }
    }
}
