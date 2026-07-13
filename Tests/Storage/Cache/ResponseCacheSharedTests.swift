//
//  ResponseCacheSharedTests.swift
//  AdaptyTests
//
//  Created by Aleksei Valiano on 18.05.2026.
//

#if canImport(Testing)

@testable import Adapty
import Foundation
import Testing

extension ResponseCacheTests {
    @Suite("shared cache (profileId: nil)")
    struct SharedCacheTests {
        private let sharedKey = Cache.ItemKey(profileId: nil, itemType: .uischema, itemId: "vc-1")
        private let payload = TestPayload(id: "x", value: 1)
        private let altPayload = TestPayload(id: "y", value: 2)

        @Test func write_and_read_shared_entry() async throws {
            let root = await prepareCacheTest()
            defer { cleanupCacheTest(root) }

            _ = try await Cache.write(payload.encoded(), key: sharedKey, dataVersion: 0) { _, _ in true }

            let value: TestPayload? = await Cache.read(
                sharedKey,
                accept: { _ in true },
                decode: TestPayload.decode(_:)
            )
            #expect(value == payload)
        }

        @Test func touch_shared_entry_updates_lastAccessedAt() async throws {
            let root = await prepareCacheTest()
            defer { cleanupCacheTest(root) }

            _ = try await Cache.write(payload.encoded(), key: sharedKey, dataVersion: 0) { _, _ in true }
            let before = await readMetaFromDisk(for: sharedKey)?.lastAccessedAt

            try await Task.sleep(nanoseconds: 10_000_000) // 10ms

            let touched = await Cache.touch(sharedKey) { _ in true }
            #expect(touched)

            let after = await readMetaFromDisk(for: sharedKey)?.lastAccessedAt
            if let before, let after {
                #expect(after > before)
            }
        }

        @Test func shared_directory_resolves_to_shared_folder() async {
            _ = await prepareCacheTest()
            let dir = await Cache.directory(forProfileId: nil)
            let root = await Cache.rootDirectory
            #expect(dir.lastPathComponent == "shared")
            #expect(dir.deletingLastPathComponent().path == root.path)
            cleanupCacheTest(root)
        }

        @Test func shared_and_profile_keys_with_same_itemId_are_isolated() async throws {
            let root = await prepareCacheTest()
            defer { cleanupCacheTest(root) }

            let profileKey = Cache.ItemKey(profileId: "p1", itemType: .uischema, itemId: "vc-1")
            // Same itemType + itemId, but shared (profileId == nil) and profile-scoped.

            _ = try await Cache.write(payload.encoded(), key: sharedKey, dataVersion: 0) { _, _ in true }
            _ = try await Cache.write(altPayload.encoded(), key: profileKey, dataVersion: 0) { _, _ in true }

            // Both entries exist on disk in different directories.
            let sharedFiles = await filesExist(for: sharedKey)
            let profileFiles = await filesExist(for: profileKey)
            #expect(sharedFiles.meta && sharedFiles.body)
            #expect(profileFiles.meta && profileFiles.body)
            let sharedPath = await sharedKey.dataFileURL.path
            let profilePath = await profileKey.dataFileURL.path
            #expect(sharedPath != profilePath)

            // Reads return their own payloads.
            let sharedValue: TestPayload? = await Cache.read(
                sharedKey,
                accept: { _ in true },
                decode: TestPayload.decode(_:)
            )
            let profileValue: TestPayload? = await Cache.read(
                profileKey,
                accept: { _ in true },
                decode: TestPayload.decode(_:)
            )
            #expect(sharedValue == payload)
            #expect(profileValue == altPayload)
        }

        @Test func writeOrRead_with_shared_key() async throws {
            let root = await prepareCacheTest()
            defer { cleanupCacheTest(root) }

            let result = try await Cache.writeOrRead(
                payload.encoded(),
                key: sharedKey,
                dataVersion: 0,
                accept: { _, _ in true },
                decode: TestPayload.decode(_:)
            )
            #expect(result == payload)

            let cached: TestPayload? = await Cache.read(
                sharedKey,
                accept: { _ in true },
                decode: TestPayload.decode(_:)
            )
            #expect(cached == payload)
        }
    }
}

#endif
