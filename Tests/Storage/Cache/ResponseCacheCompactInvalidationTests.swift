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
            _ = try await Cache.write(payload.encoded(), key: key, dataVersion: 0) { _, _ in true }

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
            _ = try await Cache.write(payload.encoded(), key: k1, dataVersion: 0) { _, _ in true }
            _ = try await Cache.write(payload.encoded(), key: k2, dataVersion: 0) { _, _ in true }

            await removeCacheItem(for: k1)

            let f1 = await filesExist(for: k1)
            let f2 = await filesExist(for: k2)
            #expect(!f1.meta && !f1.body)
            #expect(f2.meta && f2.body)
        }

        @Test func removeOtherProfiles_keeps_current_and_shared() async throws {
            let root = await prepareCacheTest()
            defer { cleanupCacheTest(root) }

            let kCurrent = Cache.ItemKey(profileId: "p1", itemType: .flow, itemId: "a")
            let kOther = Cache.ItemKey(profileId: "p2", itemType: .flow, itemId: "a")
            let kShared = Cache.ItemKey(profileId: nil, itemType: .flowLayout, itemId: "s")
            _ = try await Cache.write(payload.encoded(), key: kCurrent, dataVersion: 0) { _, _ in true }
            _ = try await Cache.write(payload.encoded(), key: kOther, dataVersion: 0) { _, _ in true }
            _ = try await Cache.write(payload.encoded(), key: kShared, dataVersion: 0) { _, _ in true }

            await Cache.removeOtherProfiles(userId("p1"))

            let current = await filesExist(for: kCurrent)
            let other = await filesExist(for: kOther)
            let shared = await filesExist(for: kShared)
            #expect(current.meta && current.body)
            #expect(!other.meta && !other.body)
            #expect(shared.meta && shared.body)

            // The other profile's root folder is removed entirely.
            let otherProfileDir = await Cache.directory(forProfileId: "p2")
            #expect(!FileManager.default.fileExists(atPath: otherProfileDir.path))
        }

        @Test func removeOtherProfiles_noop_when_root_missing() async {
            let root = await prepareCacheTest()
            defer { cleanupCacheTest(root) }
            // root not created yet (no writes). Must not crash.
            await Cache.removeOtherProfiles(userId("p1"))
            #expect(!FileManager.default.fileExists(atPath: root.path))
        }

        @Test func removeOtherProfiles_noop_when_only_current_and_shared() async throws {
            let root = await prepareCacheTest()
            defer { cleanupCacheTest(root) }

            let kCurrent = Cache.ItemKey(profileId: "p1", itemType: .flow, itemId: "a")
            let kShared = Cache.ItemKey(profileId: nil, itemType: .flowLayout, itemId: "s")
            _ = try await Cache.write(payload.encoded(), key: kCurrent, dataVersion: 0) { _, _ in true }
            _ = try await Cache.write(payload.encoded(), key: kShared, dataVersion: 0) { _, _ in true }

            await Cache.removeOtherProfiles(userId("p1"))

            // Nothing removed; both entries intact.
            let current = await filesExist(for: kCurrent)
            let shared = await filesExist(for: kShared)
            #expect(current.meta && current.body)
            #expect(shared.meta && shared.body)
        }

        @Test func removeOtherProfiles_removes_all_when_profileId_unknown() async throws {
            let root = await prepareCacheTest()
            defer { cleanupCacheTest(root) }

            let k1 = Cache.ItemKey(profileId: "p1", itemType: .flow, itemId: "a")
            let k2 = Cache.ItemKey(profileId: "p2", itemType: .flow, itemId: "a")
            let kShared = Cache.ItemKey(profileId: nil, itemType: .flowLayout, itemId: "s")
            _ = try await Cache.write(payload.encoded(), key: k1, dataVersion: 0) { _, _ in true }
            _ = try await Cache.write(payload.encoded(), key: k2, dataVersion: 0) { _, _ in true }
            _ = try await Cache.write(payload.encoded(), key: kShared, dataVersion: 0) { _, _ in true }

            // Profile "p3" has no directory; both p1 and p2 are "other".
            await Cache.removeOtherProfiles(userId("p3"))

            let f1 = await filesExist(for: k1)
            let f2 = await filesExist(for: k2)
            let fs = await filesExist(for: kShared)
            #expect(!f1.meta && !f1.body)
            #expect(!f2.meta && !f2.body)
            #expect(fs.meta && fs.body, "shared cache must always survive removeOtherProfiles")
        }

        @Test func removeAll_deletes_root() async throws {
            let root = await prepareCacheTest()
            defer { cleanupCacheTest(root) }

            let key = Cache.ItemKey(profileId: "p1", itemType: .flow, itemId: "a")
            _ = try await Cache.write(payload.encoded(), key: key, dataVersion: 0) { _, _ in true }

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
            _ = try await Cache.write(payload.encoded(), key: key, dataVersion: 0) { _, _ in true }
            await Cache.removeAll()

            // A write after removeAll must succeed.
            _ = try await Cache.write(payload.encoded(), key: key, dataVersion: 0) { _, _ in true }

            let files = await filesExist(for: key)
            #expect(files.meta && files.body)

            // Verify isExcludedFromBackup was set on the recreated rootDirectory.
            // The attribute is readable on both iOS and macOS (the behavioral effect
            // is iOS-only, but the resource value is honored cross-platform).
            let rootURL = await Cache.rootDirectory
            let values = try rootURL.resourceValues(forKeys: [.isExcludedFromBackupKey])
            #expect(values.isExcludedFromBackup == true)
        }

        // MARK: - cleanup()

        @Test func cleanup_noop_when_root_missing() async {
            let root = await prepareCacheTest()
            defer { cleanupCacheTest(root) }
            // root not created yet (no writes). cleanup must not crash.
            await Cache.cleanup()
        }

        @Test func cleanup_removes_orphan_meta() async throws {
            let root = await prepareCacheTest()
            defer { cleanupCacheTest(root) }

            let key = Cache.ItemKey(profileId: "p1", itemType: .flow, itemId: "a")
            _ = try await Cache.write(payload.encoded(), key: key, dataVersion: 0) { _, _ in true }
            await removeBodyOnly(for: key)

            await Cache.cleanup()

            let files = await filesExist(for: key)
            #expect(!files.meta && !files.body)
        }

        @Test func cleanup_removes_orphan_body() async throws {
            let root = await prepareCacheTest()
            defer { cleanupCacheTest(root) }

            let key = Cache.ItemKey(profileId: "p1", itemType: .flow, itemId: "a")
            _ = try await Cache.write(payload.encoded(), key: key, dataVersion: 0) { _, _ in true }
            await removeMetaOnly(for: key)

            await Cache.cleanup()

            let files = await filesExist(for: key)
            #expect(!files.meta && !files.body)
        }

        @Test func cleanup_keeps_valid_pair_intact() async throws {
            let root = await prepareCacheTest()
            defer { cleanupCacheTest(root) }

            let key = Cache.ItemKey(profileId: "p1", itemType: .flow, itemId: "a")
            _ = try await Cache.write(payload.encoded(), key: key, dataVersion: 0) { _, _ in true }

            await Cache.cleanup()

            let files = await filesExist(for: key)
            #expect(files.meta && files.body)

            // And the entry is still readable.
            let value: TestPayload? = await Cache.read(
                key,
                decode: TestPayload.decode(_:)
            )
            #expect(value == payload)
        }

        @Test func cleanup_removes_body_written_without_meta() async throws {
            // Crash between body-write and meta-write: body on disk, meta never created.
            // Distinct from cleanup_removes_orphan_body (which removes meta after a full write).
            let root = await prepareCacheTest()
            defer { cleanupCacheTest(root) }

            let key = Cache.ItemKey(profileId: "p1", itemType: .flow, itemId: "a")
            try await writeRawBody(payload.encoded(), for: key)

            await Cache.cleanup()
            let files = await filesExist(for: key)
            #expect(!files.body)
        }

        @Test func cleanup_keeps_other_profile_directories() async throws {
            // cleanup() does not touch foreign profile directories — that's
            // removeOtherProfiles' job. cleanup only sanitizes structure.
            let root = await prepareCacheTest()
            defer { cleanupCacheTest(root) }

            let kCurrent = Cache.ItemKey(profileId: "p1", itemType: .flow, itemId: "a")
            let kOther = Cache.ItemKey(profileId: "p2", itemType: .flow, itemId: "a")
            _ = try await Cache.write(payload.encoded(), key: kCurrent, dataVersion: 0) { _, _ in true }
            _ = try await Cache.write(payload.encoded(), key: kOther, dataVersion: 0) { _, _ in true }

            await Cache.cleanup()

            let current = await filesExist(for: kCurrent)
            let other = await filesExist(for: kOther)
            #expect(current.meta && current.body)
            #expect(other.meta && other.body)
        }

        @Test func cleanup_handles_shared_directory() async throws {
            let root = await prepareCacheTest()
            defer { cleanupCacheTest(root) }

            // Valid shared entry + orphan body in shared + stray unknown dir in shared.
            let validShared = Cache.ItemKey(profileId: nil, itemType: .flowLayout, itemId: "ok")
            let orphanShared = Cache.ItemKey(profileId: nil, itemType: .flowLayout, itemId: "orphan")
            _ = try await Cache.write(payload.encoded(), key: validShared, dataVersion: 0) { _, _ in true }
            _ = try await Cache.write(payload.encoded(), key: orphanShared, dataVersion: 0) { _, _ in true }
            await removeMetaOnly(for: orphanShared)

            let sharedDir = await Cache.directory(forProfileId: nil)
            let strayDir = sharedDir.appendingPathComponent("legacy_v0", isDirectory: true)
            try FileManager.default.createDirectory(at: strayDir, withIntermediateDirectories: true)
            try Data("stale".utf8).write(to: strayDir.appendingPathComponent("foo.data"))

            await Cache.cleanup()

            let validFiles = await filesExist(for: validShared)
            let orphanFiles = await filesExist(for: orphanShared)
            #expect(validFiles.meta && validFiles.body, "valid shared entry must survive")
            #expect(!orphanFiles.body, "orphan body in shared must be removed")
            #expect(!FileManager.default.fileExists(atPath: strayDir.path),
                    "unknown item-type dir inside shared/ must be removed")
        }

        @Test func cleanup_ignores_stray_file_at_root_level() async throws {
            // A non-directory entry directly inside rootDirectory must not crash cleanup.
            // Current behavior: such files are left in place (cleanup only walks
            // into subdirectories). This test documents that contract.
            let root = await prepareCacheTest()
            defer { cleanupCacheTest(root) }

            let key = Cache.ItemKey(profileId: "p1", itemType: .flow, itemId: "a")
            _ = try await Cache.write(payload.encoded(), key: key, dataVersion: 0) { _, _ in true }

            let strayFile = root.appendingPathComponent("README.txt")
            try Data("noise".utf8).write(to: strayFile)

            await Cache.cleanup()

            let files = await filesExist(for: key)
            #expect(files.meta && files.body)
            #expect(FileManager.default.fileExists(atPath: strayFile.path))
        }

        @Test func cleanup_removes_unknown_item_type_directories_in_all_profiles() async throws {
            let root = await prepareCacheTest()
            defer { cleanupCacheTest(root) }

            let k1 = Cache.ItemKey(profileId: "p1", itemType: .flow, itemId: "a")
            let k2 = Cache.ItemKey(profileId: "p2", itemType: .flow, itemId: "a")
            _ = try await Cache.write(payload.encoded(), key: k1, dataVersion: 0) { _, _ in true }
            _ = try await Cache.write(payload.encoded(), key: k2, dataVersion: 0) { _, _ in true }

            // Plant unknown ItemType directories in both profiles.
            let profileDir1 = await Cache.directory(forProfileId: "p1")
            let profileDir2 = await Cache.directory(forProfileId: "p2")
            let strayDir1 = profileDir1.appendingPathComponent("legacy_v0", isDirectory: true)
            let strayDir2 = profileDir2.appendingPathComponent("legacy_v0", isDirectory: true)
            try FileManager.default.createDirectory(at: strayDir1, withIntermediateDirectories: true)
            try FileManager.default.createDirectory(at: strayDir2, withIntermediateDirectories: true)
            try Data("stale".utf8).write(to: strayDir1.appendingPathComponent("foo.data"))
            try Data("stale".utf8).write(to: strayDir2.appendingPathComponent("foo.data"))

            await Cache.cleanup()

            // Valid entries survived; both foreign directories removed.
            let f1 = await filesExist(for: k1)
            let f2 = await filesExist(for: k2)
            #expect(f1.meta && f1.body)
            #expect(f2.meta && f2.body)
            #expect(!FileManager.default.fileExists(atPath: strayDir1.path))
            #expect(!FileManager.default.fileExists(atPath: strayDir2.path))
        }
    }
}

#endif
