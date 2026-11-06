@testable import Adapty
import Foundation
import Testing

@Suite("Profile virtual currencies")
struct VirtualCurrenciesTests {
    @Test("Currency identifiers are open, case-sensitive strings")
    func identifiers() throws {
        #expect(AdaptyVirtualCurrency.Coins == AdaptyVirtualCurrency("COINS"))
        #expect(AdaptyVirtualCurrency.Gems == AdaptyVirtualCurrency(rawValue: "GEMS"))
        #expect(AdaptyVirtualCurrency("coins") != .Coins)
        let currency = AdaptyVirtualCurrency("custom_currency-42")
        #expect(currency.rawValue == "custom_currency-42")
        let encoded = try Json.encode(currency)
        #expect(encoded == Json(#""custom_currency-42""#))
        #expect(try encoded.decode(AdaptyVirtualCurrency.self) == currency)
    }

    @Test("Balances decode from the attributes of a backend profile response")
    func backendResponse() throws {
        let json = Json("""
        {
          "data": {
            "type": "adapty_analytics_profile", "id": "profile",
            "attributes": {
              "profile_id": "profile", "segment_hash": "segment", "timestamp": 1762440000000,
              "virtual_currencies": {
                "COINS": {"available": 1250}, "GEMS": {"available": 0},
                "custom_currency-42": {"available": 17}, "coins": {"available": 1}
              }
            }
          }
        }
        """)
        let profile = try json.decode(Backend.Response.Data<AdaptyProfile>.self).value
        #expect(profile.virtualCurrencies.count == 4)
        #expect(profile.virtualCurrencies[.Coins]?.available == 1250)
        #expect(profile.virtualCurrencies[.Gems]?.available == 0)
        #expect(profile.virtualCurrencies[AdaptyVirtualCurrency("custom_currency-42")]?.available == 17)
        #expect(profile.virtualCurrencies[AdaptyVirtualCurrency("coins")]?.available == 1)
    }

    @Test("Missing, null and empty currency maps decode as an empty dictionary", arguments: [
        "",
        #", "virtual_currencies": null"#,
        #", "virtual_currencies": {}"#,
    ])
    func absentBalances(field: String) throws {
        let profile = try decodeProfile(field: field)
        #expect(profile.virtualCurrencies.isEmpty)
        let restored = try Json.encode(profile).decode(AdaptyProfile.self)
        #expect(restored.virtualCurrencies.isEmpty)
    }

    @Test("Each balance requires an unsigned integer", arguments: [
        "{}",
        #"{"available": null}"#,
        #"{"available": -1}"#,
        #"{"available": 1.5}"#,
        #"{"available": "1250"}"#,
        #"{"available": 18446744073709551616}"#,
    ])
    func invalidBalances(balance: String) {
        #expect(throws: DecodingError.self) {
            try decodeProfile(field: #", "virtual_currencies": {"COINS": "# + balance + "}")
        }
    }

    @Test("Balances preserve the full UInt range through profile storage")
    func storageRoundTrip() throws {
        let profile = try decodeProfile(field: #", "virtual_currencies": {"COINS": {"available": "# + String(UInt.max) + "}}")
        #expect(profile.virtualCurrencies[.Coins]?.available == UInt.max)
        let restored = try #require(try Storage.decode(AdaptyProfile.self, from: Storage.encode(profile)))
        #expect(restored == profile)
        #expect(restored.virtualCurrencies[.Coins]?.available == UInt.max)
    }

    @Test("A balance change affects profile equality and set membership")
    func equality() throws {
        let first = try decodeProfile(field: #", "virtual_currencies": {"COINS": {"available": 1}}"#)
        let second = try decodeProfile(field: #", "virtual_currencies": {"COINS": {"available": 2}}"#)
        #expect(first != second)
        #expect(Set([first, second]).count == 2)
    }

    @Test("Offline profiles start empty and preserve balances when an anonymous user is identified")
    @AdaptyActor
    func offlineProfiles() throws {
        let profile = try decodeProfile(field: #", "virtual_currencies": {"COINS": {"available": 1250}}"#)
        let empty = OfflineProfileManager(userId: profile.userId)
        #expect(empty.currentProfile.virtualCurrencies.isEmpty)
        let identified = try #require(OfflineProfileManager.ifNeedCreateNewUser(profile, nil, "user_42", nil))
        #expect(identified.currentProfile.customerUserId == "user_42")
        #expect(identified.currentProfile.virtualCurrencies == profile.virtualCurrencies)
    }

    private func decodeProfile(field: String) throws -> AdaptyProfile {
        try Json(data: Data((#"{"profile_id": "profile", "segment_hash": "segment""# + field + "}").utf8)).decode(AdaptyProfile.self)
    }
}
