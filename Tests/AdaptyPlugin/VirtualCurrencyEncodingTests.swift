@testable import Adapty
@testable import AdaptyPlugin
import Foundation
import Testing

@Suite("Plugin virtual currency encoding")
struct VirtualCurrencyEncodingTests {
    @Test("Direct profiles, success responses and profile events encode currency maps as JSON objects")
    func balancesEncoding() throws {
        let profile = try Json(#"""
        {
          "profile_id": "profile", "segment_hash": "segment",
          "virtual_currencies": {
            "COINS": {"available": 1250}, "GEMS": {"available": 0},
            "CUSTOM": {"available": 42}
          }
        }
        """#).decode(AdaptyProfile.self)
        let direct = try object(profile.asAdaptyJsonData)
        let response = try #require(try object(AdaptyJsonData.success(profile))["success"] as? [String: Any])
        let event = Event.DidLoadLatestProfile(profile: profile)
        let eventProfile = try #require(try object(event.asAdaptyJsonData)["profile"] as? [String: Any])

        for result in [direct, response, eventProfile] {
            let balances = try #require(result["virtual_currencies"] as? [String: [String: Any]])
            #expect(balances.count == 3)
            #expect(balances["COINS"]?["available"] as? UInt == 1250)
            #expect(balances["GEMS"]?["available"] as? UInt == 0)
            #expect(balances["CUSTOM"]?["available"] as? UInt == 42)
            let restored = try Json(deserilized: result).decode(AdaptyProfile.self)
            #expect(restored.virtualCurrencies == profile.virtualCurrencies)
        }
    }

    @Test("Plugin encoding preserves compatibility with profiles without virtual currencies")
    func absentBalancesEncoding() throws {
        let profile = try Json(#"{"profile_id": "profile", "segment_hash": "segment"}"#).decode(AdaptyProfile.self)
        #expect(try object(profile.asAdaptyJsonData)["virtual_currencies"] == nil)
    }

    private func object(_ data: Data) throws -> [String: Any] {
        try #require(try Json(data: data).deserilized as? [String: Any])
    }
}
