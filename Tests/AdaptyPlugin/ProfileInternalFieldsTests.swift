@testable import Adapty
@testable import AdaptyPlugin
import Foundation
import Testing

@Suite("Profile internal fields")
struct ProfileInternalFieldsTests {
    @Test("Renewal signature survives storage and encoding in plugin profiles, responses and events")
    func renewalSignatureEncoding() throws {
        let input = Data(profileJSON.utf8)
        let decoder = JSONDecoder()
        Backend.configure(jsonDecoder: decoder)
        let profile = try decoder.decode(AdaptyProfile.self, from: input)
        let accessLevel = try #require(profile.accessLevels["premium"])
        #expect(accessLevel.renewalInfoSignedAt != nil)

        let stored = try Storage.encode(profile)
        let restored = try #require(try Storage.decode(AdaptyProfile.self, from: stored))
        #expect(restored.accessLevels["premium"] == accessLevel)

        let inputObject = try object(input)
        let expected = try #require((inputObject["paid_access_levels"] as? [String: Any])?["premium"] as? [String: Any])

        let direct = try object(profile.asAdaptyJsonData)
        let response = try #require(try object(AdaptyJsonData.success(profile))["success"] as? [String: Any])
        let event = Event.DidLoadLatestProfile(profile: profile)
        let eventProfile = try #require(try object(event.asAdaptyJsonData)["profile"] as? [String: Any])

        for result in [direct, response, eventProfile] {
            let actual = try #require((result["paid_access_levels"] as? [String: Any])?["premium"] as? [String: Any])
            #expect(NSDictionary(dictionary: actual).isEqual(to: expected))
        }
    }

    @Test("Older profiles without a renewal signature still decode")
    func absentRenewalSignature() throws {
        var input = try object(Data(profileJSON.utf8))
        var levels = try #require(input["paid_access_levels"] as? [String: [String: Any]])
        levels["premium"]?.removeValue(forKey: "renewal_info_signed_at")
        input["paid_access_levels"] = levels
        let decoder = JSONDecoder()
        Backend.configure(jsonDecoder: decoder)
        let profile = try decoder.decode(AdaptyProfile.self, from: JSONSerialization.data(withJSONObject: input))
        let accessLevel = try #require(profile.accessLevels["premium"])
        #expect(accessLevel.renewalInfoSignedAt == nil)
    }

    private func object(_ data: Data) throws -> [String: Any] {
        try #require(try JSONSerialization.jsonObject(with: data) as? [String: Any])
    }

    private let profileJSON = #"""
    {
      "profile_id": "profile", "segment_hash": "segment",
      "paid_access_levels": {
        "premium": {
          "id": "premium", "is_active": true,
          "vendor_product_id": "yearly", "store": "app_store",
          "activated_at": "2026-01-01T00:00:00.000Z",
          "renewed_at": "2026-09-01T00:00:00.000Z",
          "expires_at": "2026-10-01T00:00:00.000Z",
          "is_lifetime": false,
          "active_introductory_offer_type": "free_trial",
          "active_promotional_offer_type": "pay_as_you_go",
          "active_promotional_offer_id": "promo", "offer_id": "offer",
          "will_renew": false, "is_in_grace_period": false,
          "unsubscribed_at": "2026-09-29T12:00:00.000Z",
          "billing_issue_detected_at": "2026-08-31T00:00:00.000Z",
          "starts_at": "2026-01-01T00:00:00.000Z",
          "cancellation_reason": "voluntarily_cancelled", "is_refund": false,
          "billing_plan_id": "monthly",
          "commitment": {
            "billing_period_number": 9, "total_billing_periods": 12,
            "expires_at": "2027-01-01T00:00:00.000Z"
          },
          "renewal_info_signed_at": "2026-09-29T12:10:00.123Z"
        }
      }
    }
    """#
}
