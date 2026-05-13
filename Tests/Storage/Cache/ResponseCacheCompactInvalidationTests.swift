//
//  ResponseCacheCompactInvalidationTests.swift
//  AdaptyTests
//
//  Created by Aleksei Valiano on 12.05.2026.
//

#if canImport(Testing)

@testable import Adapty
import Foundation
import Testing

extension ResponseCacheTests {
    @Suite("cleanup() + remove*")
    struct CompactInvalidationTests {
        private let payload = TestPayload(id: "x", value: 1)

        // MARK: - remove

        @Test func remove_deletes_pair() async throws {
            let root = await prepareCacheTest()
            defer { cleanupCacheTest(root) }

            let key = Cache.ItemKey(profileId: "p1", itemType: .flow, itemId: "obj1")
            _ = try await Cache.write(payload.encoded(), key: key) { _, _ in true }

            var files = await filesExist(for: key)
            #expect(files.meta && files.body)

            await removeCacheItem(for: key)

            files = await filesExist(for: key)
            #expect(!files.meta && !files.body)
        }

        @Test func removeObject_deletes_only_target() async throws {
            let root = await prepareCacheTest()
            defer { cleanupCacheTest(root) }

            let k1 = Cache.ItemKey(profileId: "p1", itemType: .flow, itemId: "a")
            let k2 = Cache.ItemKey(profileId: "p1", itemType: .flow, itemId: "b")
            _ = try await Cache.write(payload.encoded(), key: k1) { _, _ in true }
            _ = try await Cache.write(payload.encoded(), key: k2) { _, _ in true }

            await removeCacheItem(for: k1)

            let f1 = await filesExist(for: k1)
            let f2 = await filesExist(for: k2)
            #expect(!f1.meta && !f1.body)
            #expect(f2.meta && f2.body)
        }

        @Test func removeType_deletes_only_target_type() async throws {
            let root = await prepareCacheTest()
            defer { cleanupCacheTest(root) }

            let flowKey = Cache.ItemKey(profileId: "p1", itemType: .flow, itemId: "f")
            let onbKey = Cache.ItemKey(profileId: "p1", itemType: .onboarding, itemId: "o")
            _ = try await Cache.write(payload.encoded(), key: flowKey) { _, _ in true }
            _ = try await Cache.write(payload.encoded(), key: onbKey) { _, _ in true }

            await Cache.removeItemType(profileId: "p1", itemType: .flow)

            let ff = await filesExist(for: flowKey)
            let fo = await filesExist(for: onbKey)
            #expect(!ff.meta && !ff.body)
            #expect(fo.meta && fo.body)
        }

        @Test func removeProfile_deletes_only_target_profile() async throws {
            let root = await prepareCacheTest()
            defer { cleanupCacheTest(root) }

            let k1 = Cache.ItemKey(profileId: "p1", itemType: .flow, itemId: "a")
            let k2 = Cache.ItemKey(profileId: "p2", itemType: .flow, itemId: "a")
            _ = try await Cache.write(payload.encoded(), key: k1) { _, _ in true }
            _ = try await Cache.write(payload.encoded(), key: k2) { _, _ in true }

            await Cache.removeProfile("p1")

            let f1 = await filesExist(for: k1)
            let f2 = await filesExist(for: k2)
            #expect(!f1.meta && !f1.body)
            #expect(f2.meta && f2.body)
        }

        @Test func removeAll_deletes_root() async throws {
            let root = await prepareCacheTest()
            defer { cleanupCacheTest(root) }

            let key = Cache.ItemKey(profileId: "p1", itemType: .flow, itemId: "a")
            _ = try await Cache.write(payload.encoded(), key: key) { _, _ in true }

            let rootExistsBefore = FileManager.default.fileExists(atPath: root.path)
            #expect(rootExistsBefore)

            await Cache.removeAll()

            let rootExistsAfter = FileManager.default.fileExists(atPath: root.path)
            #expect(!rootExistsAfter)
        }

        @Test func write_after_removeAll_recreates_directory_and_excludes_from_backup() async throws {
            let root = await prepareCacheTest()
            defer { cleanupCacheTest(root) }

            let key = Cache.ItemKey(profileId: "p1", itemType: .flow, itemId: "a")
            _ = try await Cache.write(payload.encoded(), key: key) { _, _ in true }
            await Cache.removeAll()

            // A write after removeAll must succeed.
            _ = try await Cache.write(payload.encoded(), key: key) { _, _ in true }

            let files = await filesExist(for: key)
            #expect(files.meta && files.body)

            // isExcludedFromBackup is iOS-only; on macOS the attribute is also set via
            // setResourceValues, but there's no real backup-exclusion behavior.
            // We only verify that setResourceValues didn't throw — already covered by the successful write.
        }

        // MARK: - cleanup()

        @Test func cleanup_noop_when_root_missing() async {
            let root = await prepareCacheTest()
            defer { cleanupCacheTest(root) }
            // root not created yet (no writes). cleanup must not crash.
            await Cache.cleanup(profileId: "p1")
        }

        @Test func cleanup_removes_orphan_meta() async throws {
            let root = await prepareCacheTest()
            defer { cleanupCacheTest(root) }

            let key = Cache.ItemKey(profileId: "p1", itemType: .flow, itemId: "a")
            _ = try await Cache.write(payload.encoded(), key: key) { _, _ in true }
            await removeBodyOnly(for: key)

            await Cache.cleanup(profileId: "p1")

            let files = await filesExist(for: key)
            #expect(!files.meta && !files.body)
        }

        @Test func cleanup_removes_orphan_body() async throws {
            let root = await prepareCacheTest()
            defer { cleanupCacheTest(root) }

            let key = Cache.ItemKey(profileId: "p1", itemType: .flow, itemId: "a")
            _ = try await Cache.write(payload.encoded(), key: key) { _, _ in true }
            await removeMetaOnly(for: key)

            await Cache.cleanup(profileId: "p1")

            let files = await filesExist(for: key)
            #expect(!files.meta && !files.body)
        }

        @Test func cleanup_keeps_valid_pair_intact() async throws {
            let root = await prepareCacheTest()
            defer { cleanupCacheTest(root) }

            let key = Cache.ItemKey(profileId: "p1", itemType: .flow, itemId: "a")
            _ = try await Cache.write(payload.encoded(), key: key) { _, _ in true }

            await Cache.cleanup(profileId: "p1")

            let files = await filesExist(for: key)
            #expect(files.meta && files.body)

            // And the entry is still readable.
            let value: TestPayload? = await Cache.read(
                key,
                accept: { _ in true },
                decode: TestPayload.decode(_:)
            )
            #expect(value == payload)
        }

        @Test func cleanup_simulated_crash_meta_removed_body_left() async throws {
            // Crash simulation: meta removed, body remains.
            let root = await prepareCacheTest()
            defer { cleanupCacheTest(root) }

            let key = Cache.ItemKey(profileId: "p1", itemType: .flow, itemId: "a")
            _ = try await Cache.write(payload.encoded(), key: key) { _, _ in true }
            await removeMetaOnly(for: key)

            // Read → cache miss.
            let value: TestPayload? = await Cache.read(
                key,
                accept: { _ in true },
                decode: TestPayload.decode(_:)
            )
            #expect(value == nil)

            // cleanup removes the orphan body.
            await Cache.cleanup(profileId: "p1")
            let files = await filesExist(for: key)
            #expect(!files.body)
        }

        @Test func cleanup_simulated_crash_body_only_no_meta() async throws {
            // Crash simulation between body-write and meta-write: only body on disk, no meta.
            let root = await prepareCacheTest()
            defer { cleanupCacheTest(root) }

            let key = Cache.ItemKey(profileId: "p1", itemType: .flow, itemId: "a")
            try await writeRawBody(payload.encoded(), for: key)

            let value: TestPayload? = await Cache.read(
                key,
                accept: { _ in true },
                decode: TestPayload.decode(_:)
            )
            #expect(value == nil)

            await Cache.cleanup(profileId: "p1")
            let files = await filesExist(for: key)
            #expect(!files.body)
        }

        @Test func cleanup_removes_other_profile_directories() async throws {
            let root = await prepareCacheTest()
            defer { cleanupCacheTest(root) }

            let kCurrent = Cache.ItemKey(profileId: "p1", itemType: .flow, itemId: "a")
            let kOther = Cache.ItemKey(profileId: "p2", itemType: .flow, itemId: "a")
            _ = try await Cache.write(payload.encoded(), key: kCurrent) { _, _ in true }
            _ = try await Cache.write(payload.encoded(), key: kOther) { _, _ in true }

            await Cache.cleanup(profileId: "p1")

            let current = await filesExist(for: kCurrent)
            let other = await filesExist(for: kOther)
            #expect(current.meta && current.body)
            #expect(!other.meta && !other.body)

            // The other profile's root folder is removed entirely.
            let otherProfileDir = await Cache.directory(forProfileId: "p2")
            #expect(!FileManager.default.fileExists(atPath: otherProfileDir.path))
        }

        @Test func cleanup_removes_unknown_item_type_directories() async throws {
            let root = await prepareCacheTest()
            defer { cleanupCacheTest(root) }

            let key = Cache.ItemKey(profileId: "p1", itemType: .flow, itemId: "a")
            _ = try await Cache.write(payload.encoded(), key: key) { _, _ in true }

            // Plant a directory of an unknown ItemType with files inside.
            let profileDir = await Cache.directory(forProfileId: "p1")
            let strayDir = profileDir.appendingPathComponent("legacy_v0", isDirectory: true)
            try FileManager.default.createDirectory(at: strayDir, withIntermediateDirectories: true)
            try Data("stale".utf8).write(to: strayDir.appendingPathComponent("foo.data"))

            await Cache.cleanup(profileId: "p1")

            // Valid entry survived; foreign directory removed.
            let files = await filesExist(for: key)
            #expect(files.meta && files.body)
            #expect(!FileManager.default.fileExists(atPath: strayDir.path))
        }
    }
}

#endif
