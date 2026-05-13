//
//  ResponseCacheEvictionTests.swift
//  AdaptyTests
//
//  Created by Aleksei Valiano on 12.05.2026.
//

#if canImport(Testing)

@testable import Adapty
import Foundation
import Testing

extension ResponseCacheTests {
    @Suite("eviction + grace")
    struct EvictionTests {
        /// Writes an entry with arbitrary storedAt/lastAccessedAt and a body of known size.
        /// Returns the key for later inspection.
        @Cache.Actor
        private func putEntry(
            itemId: String,
            bodySize: Int,
            storedAt: Date,
            lastAccessedAt: Date
        ) throws -> Cache.ItemKey {
            let key = Cache.ItemKey(profileId: "p1", itemType: .flow, itemId: itemId)
            let body = Data(count: bodySize)
            _ = try Cache.write(body, key: key) { _, _ in true }

            // Rewrite meta directly with the desired storedAt/lastAccessedAt.
            let existing = readMetaFromDisk(for: key)!
            let patched = Cache.Meta(
                key: Cache.ItemKey(
                    profileId: existing.key.profileId,
                    itemType: existing.key.itemType,
                    itemId: existing.key.itemId
                ),
                size: existing.size,
                locale: existing.locale,
                dataHash: existing.dataHash,
                storedAt: storedAt,
                lastAccessedAt: lastAccessedAt
            )
            try overwriteMeta(patched, for: key)
            return key
        }

        @Test func eviction_removes_oldest_by_lastAccessedAt() async throws {
            let root = await prepareCacheTest()
            defer { cleanupCacheTest(root) }

            await configureCache(maxBytes: 100, evictionGracePeriod: 3600)

            let oldStored = Date(timeIntervalSinceNow: -7200) // 2 hours ago → not grace-protected
            // Three "old" entries, 50 bytes each, different lastAccessedAt:
            let k1 = try await putEntry(itemId: "o1",
                                        bodySize: 50,
                                        storedAt: oldStored,
                                        lastAccessedAt: Date(timeIntervalSinceNow: -300)) // 5 min ago
            let k2 = try await putEntry(itemId: "o2",
                                        bodySize: 50,
                                        storedAt: oldStored,
                                        lastAccessedAt: Date(timeIntervalSinceNow: -600)) // 10 min ago (coldest)
            let k3 = try await putEntry(itemId: "o3",
                                        bodySize: 50,
                                        storedAt: oldStored,
                                        lastAccessedAt: Date(timeIntervalSinceNow: -60)) // 1 min ago

            // Total = 150 > maxBytes=100. Eviction should trigger after the next write.
            let k4 = try await putEntry(itemId: "o4",
                                        bodySize: 50,
                                        storedAt: oldStored,
                                        lastAccessedAt: Date())

            // putEntry rewrites meta bypassing enforceCacheSizeLimit, so we issue one
            // more real write on a separate key — that triggers eviction.
            let triggerKey = Cache.ItemKey(profileId: "p1", itemType: .flow, itemId: "trigger")
            _ = try await Cache.write(Data(count: 1), key: triggerKey) { _, _ in true }

            // After eviction the total size must be <= maxBytes.
            let entries = await collectAllMeta()
            let total = entries.reduce(0) { $0 + $1.size }
            #expect(total <= 100)

            // The "coldest" k2 should be removed first.
            let files2 = await filesExist(for: k2)
            #expect(!files2.meta && !files2.body)

            // The freshly-accessed (k4) survives.
            let files4 = await filesExist(for: k4)
            #expect(files4.meta && files4.body)

            // Note: something from {k1, k3} could also have been evicted —
            // we don't assert exact state, only the total-size invariant.
            _ = k1
            _ = k3
        }

        @Test func eviction_grace_protects_young_records() async throws {
            let root = await prepareCacheTest()
            defer { cleanupCacheTest(root) }

            await configureCache(maxBytes: 50, evictionGracePeriod: 3600)

            // All entries are fresh (storedAt = now) → grace protects them.
            let now = Date()
            let k1 = try await putEntry(itemId: "o1",
                                        bodySize: 40,
                                        storedAt: now,
                                        lastAccessedAt: now)
            let k2 = try await putEntry(itemId: "o2",
                                        bodySize: 40,
                                        storedAt: now,
                                        lastAccessedAt: now)
            let k3 = try await putEntry(itemId: "o3",
                                        bodySize: 40,
                                        storedAt: now,
                                        lastAccessedAt: now)

            // Trigger eviction.
            let trigger = Cache.ItemKey(profileId: "p1", itemType: .flow, itemId: "trigger")
            _ = try await Cache.write(Data(count: 1), key: trigger) { _, _ in true }

            // All three should survive despite exceeding the limit.
            for k in [k1, k2, k3] {
                let files = await filesExist(for: k)
                #expect(files.meta && files.body, "Entry \(k.itemId) is grace-protected; should not be evicted")
            }
        }

        @Test func eviction_no_op_when_under_limit() async throws {
            let root = await prepareCacheTest()
            defer { cleanupCacheTest(root) }

            await configureCache(maxBytes: 1024, evictionGracePeriod: 3600)

            let oldStored = Date(timeIntervalSinceNow: -7200)
            let k = try await putEntry(itemId: "o1",
                                       bodySize: 100,
                                       storedAt: oldStored,
                                       lastAccessedAt: oldStored)

            // Trigger eviction. Total size ~100+1 < 1024 → nothing removed.
            let trigger = Cache.ItemKey(profileId: "p1", itemType: .flow, itemId: "trigger")
            _ = try await Cache.write(Data(count: 1), key: trigger) { _, _ in true }

            let files = await filesExist(for: k)
            #expect(files.meta && files.body)
        }
    }
}

#endif
