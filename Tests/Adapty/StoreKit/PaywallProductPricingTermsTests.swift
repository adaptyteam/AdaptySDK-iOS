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

    @Test("Missing and null pricing terms retain legacy eligibility and the up-front default",
          arguments: [false, true], [false, true])
    func legacyTerms(nullTerms: Bool, promotionalEligible: Bool) throws {
        var fields: [String: Any] = [
            "billing_plan_id": NSNull(),
            "promotional_offer_id": "legacy-promo",
            "win_back_offer_id": "legacy-winback",
            "promotional_offer_eligibility": promotionalEligible,
        ]
        if nullTerms { fields["pricing_terms"] = NSNull() }
        let reference = try decode(fields)
        #expect(reference.pricingTerms == [Terms(
            billingPlan: .upFront,
            promotionalOfferId: promotionalEligible ? "legacy-promo" : nil,
            winBackOfferId: "legacy-winback"
        )])
    }

    @Test("Legacy plan and default promotional eligibility are preserved")
    func legacyMonthly() throws {
        let reference = try decode([
            "billing_plan_id": "monthly",
            "promotional_offer_id": "legacy-promo",
        ])
        #expect(reference.pricingTerms == [Terms(
            billingPlan: .monthly,
            promotionalOfferId: "legacy-promo",
            winBackOfferId: nil
        )])
    }

    @Test("Explicit pricing terms take precedence over legacy fields, including an empty array",
          arguments: [false, true])
    func newTermsOverrideLegacy(empty: Bool) throws {
        let reference = try decode([
            "pricing_terms": empty ? [] : [term("monthly", promotional: "new-promo")],
            "billing_plan_id": "up_front",
            "promotional_offer_id": "legacy-promo",
            "win_back_offer_id": "legacy-winback",
            "promotional_offer_eligibility": false,
        ])
        let expected: [Terms] = empty ? [] : [Terms(
            billingPlan: .monthly, promotionalOfferId: "new-promo", winBackOfferId: nil
        )]
        #expect(reference.pricingTerms == expected)
    }

    @Test("Storage round trips preserve pricing terms, including empty arrays",
          arguments: [false, true])
    func roundTrip(empty: Bool) throws {
        let reference = try decode([
            "pricing_terms": empty ? [] : [term("monthly", promotional: "promo", winBack: "winback")],
        ])
        let encoded = try Json.encode(reference)
        let object = try #require(encoded.deserilized as? [String: Any])
        if empty {
            #expect(object["pricing_terms"] == nil)
        } else {
            let terms = try #require(object["pricing_terms"] as? [[String: Any]])
            #expect(terms.count == 1)
        }
        let restored = try encoded.decode(DecodedReference.self).value
        #expect(restored == reference)
        let restoredAgain = try Json.encode(restored).decode(DecodedReference.self).value
        #expect(restoredAgain == reference)
    }

    private func term(_ plan: String, promotional: String? = nil, winBack: String? = nil) -> [String: Any] {
        var fields: [String: Any] = ["billing_plan_id": plan]
        fields["promotional_offer_id"] = promotional
        fields["win_back_offer_id"] = winBack
        return fields
    }

    private func decode(_ extra: [String: Any]) throws -> AdaptyFlowPaywall.ProductReference {
        var fields: [String: Any] = [
            "vendor_product_id": "com.example.yearly",
            "adapty_product_id": "product",
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
