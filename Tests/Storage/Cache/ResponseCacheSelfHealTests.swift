//
//  ResponseCacheSelfHealTests.swift
//  AdaptyTests
//
//  Created by Aleksei Valiano on 12.05.2026.
//

#if canImport(Testing)

@testable import Adapty
import Foundation
import Testing

extension ResponseCacheTests {
    @Suite("self-heal + schemaVersion")
    struct SelfHealTests {
        private let key = Cache.ItemKey(profileId: "p1", itemType: .flow, itemId: "obj1")
        private let payload = TestPayload(id: "x", value: 42)

        @Test func corrupt_meta_json_causes_self_heal() async throws {
            let root = await prepareCacheTest()
            defer { cleanupCacheTest(root) }

            _ = try await Cache.write(payload.encoded(), key: key, dataVersion: 0) { _, _ in true }

            // Overwrite .meta with garbage.
            try await writeRawMeta(Data("{ not json".utf8), for: key)

            let value: TestPayload? = await Cache.read(
                key,
                decode: TestPayload.decode(_:_:)
            )
            #expect(value == nil)

            let files = await filesExist(for: key)
            #expect(!files.meta)
            #expect(!files.body)
        }

        @Test func mismatched_profileId_in_meta_causes_self_heal() async throws {
            let root = await prepareCacheTest()
            defer { cleanupCacheTest(root) }

            _ = try await Cache.write(payload.encoded(), key: key, dataVersion: 0) { _, _ in true }

            // Construct meta with a different profileId, but write it under the original key's URL.
            let badKey = Cache.ItemKey(profileId: "different", itemType: key.itemType, itemId: key.itemId)
            let bad = Cache.Meta(
                key: badKey,
                size: 100,
                locale: nil,
                eligibleCrossABtest: false,
                dataVersion: 0,
                storedAt: Date(),
                lastAccessedAt: Date()
            )
            try await overwriteMeta(bad, for: key)

            let value: TestPayload? = await Cache.read(
                key,
                decode: TestPayload.decode(_:_:)
            )
            #expect(value == nil)

            let files = await filesExist(for: key)
            #expect(!files.meta)
            #expect(!files.body)
        }

        @Test func mismatched_profileId_nil_vs_non_nil_causes_self_heal() async throws {
            let root = await prepareCacheTest()
            defer { cleanupCacheTest(root) }

            _ = try await Cache.write(payload.encoded(), key: key, dataVersion: 0) { _, _ in true }

            // Meta written under profileId="p1" file, but with profileId=nil inside.
            let badKey = Cache.ItemKey(profileId: nil, itemType: key.itemType, itemId: key.itemId)
            let bad = Cache.Meta(
                key: badKey,
                size: 100,
                locale: nil,
                eligibleCrossABtest: false,
                dataVersion: 0,
                storedAt: Date(),
                lastAccessedAt: Date()
            )
            try await overwriteMeta(bad, for: key)

            let value: TestPayload? = await Cache.read(
                key,
                decode: TestPayload.decode(_:_:)
            )
            #expect(value == nil)

            let files = await filesExist(for: key)
            #expect(!files.meta)
            #expect(!files.body)
        }

        @Test func mismatched_itemType_in_meta_causes_self_heal() async throws {
            let root = await prepareCacheTest()
            defer { cleanupCacheTest(root) }

            _ = try await Cache.write(payload.encoded(), key: key, dataVersion: 0) { _, _ in true }

            // Meta declares a different itemType than the key requests.
            let badKey = Cache.ItemKey(profileId: key.profileId, itemType: .onboarding, itemId: key.itemId)
            let bad = Cache.Meta(
                key: badKey,
                size: 100,
                locale: nil,
                eligibleCrossABtest: false,
                dataVersion: 0,
                storedAt: Date(),
                lastAccessedAt: Date()
            )
            try await overwriteMeta(bad, for: key)

            let value: TestPayload? = await Cache.read(
                key,
                decode: TestPayload.decode(_:_:)
            )
            #expect(value == nil)

            let files = await filesExist(for: key)
            #expect(!files.meta)
            #expect(!files.body)
        }

        @Test func mismatched_itemId_in_meta_causes_self_heal() async throws {
            let root = await prepareCacheTest()
            defer { cleanupCacheTest(root) }

            _ = try await Cache.write(payload.encoded(), key: key, dataVersion: 0) { _, _ in true }

            // Meta declares a different itemId than the key requests.
            let badKey = Cache.ItemKey(profileId: key.profileId, itemType: key.itemType, itemId: "different-id")
            let bad = Cache.Meta(
                key: badKey,
                size: 100,
                locale: nil,
                eligibleCrossABtest: false,
                dataVersion: 0,
                storedAt: Date(),
                lastAccessedAt: Date()
            )
            try await overwriteMeta(bad, for: key)

            let value: TestPayload? = await Cache.read(
                key,
                decode: TestPayload.decode(_:_:)
            )
            #expect(value == nil)

            let files = await filesExist(for: key)
            #expect(!files.meta)
            #expect(!files.body)
        }

        @Test func missing_body_with_meta_present_causes_self_heal() async throws {
            let root = await prepareCacheTest()
            defer { cleanupCacheTest(root) }

            _ = try await Cache.write(payload.encoded(), key: key, dataVersion: 0) { _, _ in true }
            await removeBodyOnly(for: key)

            let value: TestPayload? = await Cache.read(
                key,
                decode: TestPayload.decode(_:_:)
            )
            #expect(value == nil)

            let files = await filesExist(for: key)
            #expect(!files.meta)
            #expect(!files.body)
        }

        @Test func missing_meta_with_body_present_is_cache_miss() async throws {
            let root = await prepareCacheTest()
            defer { cleanupCacheTest(root) }

            _ = try await Cache.write(payload.encoded(), key: key, dataVersion: 0) { _, _ in true }
            await removeMetaOnly(for: key)

            let value: TestPayload? = await Cache.read(
                key,
                decode: TestPayload.decode(_:_:)
            )
            #expect(value == nil)

            // Cache miss: meta is definitely gone. Orphan body remains — that's cleanup()'s job.
        }

        @Test func wrong_schemaVersion_in_meta_causes_self_heal() async throws {
            let root = await prepareCacheTest()
            defer { cleanupCacheTest(root) }

            _ = try await Cache.write(payload.encoded(), key: key, dataVersion: 0) { _, _ in true }

            // Patch the meta-file's schemaVersion to an unknown one.
            try await overwriteMetaSchemaVersion(99, for: key)

            let value: TestPayload? = await Cache.read(
                key,
                decode: TestPayload.decode(_:_:)
            )
            #expect(value == nil)

            let files = await filesExist(for: key)
            #expect(!files.meta)
            #expect(!files.body)
        }

        @Test func bump_schemaVersion_one_type_does_not_affect_others() async throws {
            let root = await prepareCacheTest()
            defer { cleanupCacheTest(root) }

            let flowKey = Cache.ItemKey(profileId: "p1", itemType: .flow, itemId: "f1")
            let onbKey = Cache.ItemKey(profileId: "p1", itemType: .onboarding, itemId: "o1")
            let flowPayload = TestPayload(id: "flow", value: 1)
            let onbPayload = TestPayload(id: "onb", value: 2)

            _ = try await Cache.write(flowPayload.encoded(), key: flowKey, dataVersion: 0) { _, _ in true }
            _ = try await Cache.write(onbPayload.encoded(), key: onbKey, dataVersion: 0) { _, _ in true }

            // Simulate a schema bump for flow: rewrite schemaVersion in meta to an outdated value.
            try await overwriteMetaSchemaVersion(0, for: flowKey)

            // Read flow → self-heal (schemaVersion does not match itemType.schemaVersion).
            let f: TestPayload? = await Cache.read(
                flowKey,
                decode: TestPayload.decode(_:_:)
            )
            #expect(f == nil)

            // Onboarding is untouched — reads normally.
            let o: TestPayload? = await Cache.read(
                onbKey,
                decode: TestPayload.decode(_:_:)
            )
            #expect(o == onbPayload)
        }

        @Test func touch_on_corrupted_meta_returns_false_and_self_heals() async throws {
            let root = await prepareCacheTest()
            defer { cleanupCacheTest(root) }

            _ = try await Cache.write(payload.encoded(), key: key, dataVersion: 0) { _, _ in true }
            try await writeRawMeta(Data("not-json".utf8), for: key)

            let touched = await Cache.touch(key) { _ in true }
            #expect(!touched)

            let files = await filesExist(for: key)
            #expect(!files.meta)
            #expect(!files.body)
        }
    }
}

#endif
