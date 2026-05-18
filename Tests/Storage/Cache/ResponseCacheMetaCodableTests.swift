//
//  ResponseCacheMetaCodableTests.swift
//  AdaptyTests
//
//  Created by Aleksei Valiano on 18.05.2026.
//

#if canImport(Testing)

@testable import Adapty
import Foundation
import Testing

extension ResponseCacheTests {
    @Suite("Meta codable + backwards-compat")
    struct MetaCodableTests {
        @Test func decode_meta_with_profile_field() async throws {
            let json = """
            {
                "profile": "p1",
                "type": "flow",
                "id": "obj1",
                "format": 1,
                "version": 0,
                "size": 42,
                "stored_at": 1700000000.0,
                "last_accessed_at": 1700000100.0
            }
            """.data(using: .utf8)!

            let meta = try JSONDecoder().decode(Cache.Meta.self, from: json)
            #expect(meta.key.profileId == "p1")
            #expect(meta.key.itemType == .flow)
            #expect(meta.key.itemId == "obj1")
            #expect(meta.schemaVersion == 1)
        }

        @Test func decode_meta_without_profile_field_yields_nil() async throws {
            // Shared cache entries omit the "profile" key entirely.
            let json = """
            {
                "type": "uischema",
                "id": "vc-123",
                "format": 1,
                "version": 0,
                "size": 42,
                "stored_at": 1700000000.0,
                "last_accessed_at": 1700000100.0
            }
            """.data(using: .utf8)!

            let meta = try JSONDecoder().decode(Cache.Meta.self, from: json)
            #expect(meta.key.profileId == nil)
            #expect(meta.key.itemType == .uischema)
            #expect(meta.key.itemId == "vc-123")
        }

        @Test func encode_meta_with_profile_includes_profile_key() async throws {
            let key = Cache.ItemKey(profileId: "p1", itemType: .flow, itemId: "obj1")
            let meta = Cache.Meta(
                key: key,
                size: 10,
                locale: nil,
                dataVersion: 0,
                storedAt: Date(timeIntervalSince1970: 1_700_000_000),
                lastAccessedAt: Date(timeIntervalSince1970: 1_700_000_100)
            )

            let data = try JSONEncoder().encode(meta)
            let dict = try #require(JSONSerialization.jsonObject(with: data) as? [String: Any])
            #expect(dict["profile"] as? String == "p1")
        }

        @Test func encode_meta_without_profile_omits_profile_key() async throws {
            let key = Cache.ItemKey(profileId: nil, itemType: .uischema, itemId: "vc-123")
            let meta = Cache.Meta(
                key: key,
                size: 10,
                locale: nil,
                dataVersion: 0,
                storedAt: Date(timeIntervalSince1970: 1_700_000_000),
                lastAccessedAt: Date(timeIntervalSince1970: 1_700_000_100)
            )

            let data = try JSONEncoder().encode(meta)
            let dict = try #require(JSONSerialization.jsonObject(with: data) as? [String: Any])
            #expect(dict["profile"] == nil)
        }

        @Test func roundtrip_preserves_nil_profile() async throws {
            let key = Cache.ItemKey(profileId: nil, itemType: .uischema, itemId: "vc-1")
            let original = Cache.Meta(
                key: key,
                size: 10,
                locale: "en",
                dataVersion: 0,
                storedAt: Date(timeIntervalSince1970: 1_700_000_000),
                lastAccessedAt: Date(timeIntervalSince1970: 1_700_000_100)
            )

            let encoded = try JSONEncoder().encode(original)
            let decoded = try JSONDecoder().decode(Cache.Meta.self, from: encoded)

            #expect(decoded.key.profileId == nil)
            #expect(decoded.key.itemType == .uischema)
            #expect(decoded.key.itemId == "vc-1")
            #expect(decoded.locale == "en")
        }

        @Test func encode_meta_with_nil_locale_omits_locale_key() async throws {
            let key = Cache.ItemKey(profileId: "p1", itemType: .flow, itemId: "obj1")
            let meta = Cache.Meta(
                key: key,
                size: 10,
                locale: nil,
                dataVersion: 0,
                storedAt: Date(timeIntervalSince1970: 1_700_000_000),
                lastAccessedAt: Date(timeIntervalSince1970: 1_700_000_100)
            )

            let data = try JSONEncoder().encode(meta)
            let dict = try #require(JSONSerialization.jsonObject(with: data) as? [String: Any])
            #expect(dict["locale"] == nil)
        }

        @Test func roundtrip_preserves_nil_locale() async throws {
            let key = Cache.ItemKey(profileId: "p1", itemType: .flow, itemId: "obj1")
            let original = Cache.Meta(
                key: key,
                size: 10,
                locale: nil,
                dataVersion: 0,
                storedAt: Date(timeIntervalSince1970: 1_700_000_000),
                lastAccessedAt: Date(timeIntervalSince1970: 1_700_000_100)
            )

            let encoded = try JSONEncoder().encode(original)
            let decoded = try JSONDecoder().decode(Cache.Meta.self, from: encoded)

            #expect(decoded.locale == nil)
        }

        // MARK: - dataVersion

        @Test func encode_meta_with_dataVersion_includes_version_key() async throws {
            let key = Cache.ItemKey(profileId: "p1", itemType: .flow, itemId: "obj1")
            let meta = Cache.Meta(
                key: key,
                size: 10,
                locale: nil,
                dataVersion: 42,
                storedAt: Date(timeIntervalSince1970: 1_700_000_000),
                lastAccessedAt: Date(timeIntervalSince1970: 1_700_000_100)
            )

            let data = try JSONEncoder().encode(meta)
            let dict = try #require(JSONSerialization.jsonObject(with: data) as? [String: Any])
            #expect((dict["version"] as? Int) == 42)
        }

        @Test func encode_meta_with_zero_dataVersion_writes_zero() async throws {
            let key = Cache.ItemKey(profileId: "p1", itemType: .flow, itemId: "obj1")
            let meta = Cache.Meta(
                key: key,
                size: 10,
                locale: nil,
                dataVersion: 0,
                storedAt: Date(timeIntervalSince1970: 1_700_000_000),
                lastAccessedAt: Date(timeIntervalSince1970: 1_700_000_100)
            )

            let data = try JSONEncoder().encode(meta)
            let dict = try #require(JSONSerialization.jsonObject(with: data) as? [String: Any])
            #expect((dict["version"] as? Int) == 0)
        }

        @Test func roundtrip_preserves_dataVersion() async throws {
            let key = Cache.ItemKey(profileId: "p1", itemType: .flow, itemId: "obj1")
            let original = Cache.Meta(
                key: key,
                size: 10,
                locale: nil,
                dataVersion: 1_234_567_890,
                storedAt: Date(timeIntervalSince1970: 1_700_000_000),
                lastAccessedAt: Date(timeIntervalSince1970: 1_700_000_100)
            )

            let encoded = try JSONEncoder().encode(original)
            let decoded = try JSONDecoder().decode(Cache.Meta.self, from: encoded)

            #expect(decoded.dataVersion == 1_234_567_890)
        }

        @Test func decode_meta_missing_version_field_throws() async throws {
            // dataVersion is required — missing key must fail decode (self-heal trigger).
            let json = """
            {
                "profile": "p1",
                "type": "flow",
                "id": "obj1",
                "format": 1,
                "size": 42,
                "stored_at": 1700000000.0,
                "last_accessed_at": 1700000100.0
            }
            """.data(using: .utf8)!

            #expect(throws: (any Error).self) {
                _ = try JSONDecoder().decode(Cache.Meta.self, from: json)
            }
        }
    }
}

#endif
